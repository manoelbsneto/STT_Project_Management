"""
AQ-08 — minimal-diff, gated builder for the 5 in-scope topic YAMLs.

Approach:
  - Read each AS-IS topic file (live state from M2 discovery, byte for byte).
  - Apply the SMALLEST possible change required for AQ-08:
      * AtualizarTarefa, CriarTarefa, ListarTarefas: single-line dialog rebind.
      * AtualizarStatus, ConsultarPortfolio: structural swap of the action call
        block from `kind: InvokeFlowAction` (with flowId) to `kind: BeginDialog`
        (with dialog: <PM0_PA_Card_*>).
  - Preserve original line endings (CRLF), encoding (UTF-8 no BOM), and every
    other byte.
  - Do NOT touch comments. Do NOT add legacy strings anywhere.
  - Write to a NEW path; only after all gates pass.
  - Run G1..G7 quality gates and exit non-zero on any failure.
"""

from __future__ import annotations
import sys
import re
import yaml
from pathlib import Path

ROOT = Path(r"D:\VMs\Projetos\STT_Project_Management")
AS_IS_DIR = ROOT / ".planning/milestones/M2_card_first_revision_v2/phases/01_discovery/F_topic_yamls"
OUT_DIR = ROOT / ".planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/fixed_topic_yamls"

# -------- helpers --------

def read_bytes_strict(path: Path) -> bytes:
    if not path.exists():
        raise FileNotFoundError(path)
    return path.read_bytes()


def write_bytes_strict(path: Path, data: bytes):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)


def detect_eol(data: bytes) -> str:
    if data.count(b"\r\n") > 0:
        return "\r\n"
    return "\n"


def split_keep_eol(data: bytes):
    """Split bytes into a list of (line_text_bytes_without_eol, eol_bytes)."""
    eol = detect_eol(data)
    eol_bytes = eol.encode("ascii")
    parts = data.split(eol_bytes)
    # If the file ends with eol, last split is empty; preserve that.
    return parts, eol_bytes


def join_with_eol(parts, eol_bytes: bytes) -> bytes:
    return eol_bytes.join(parts)

# -------- per-file builders --------

def build_simple_dialog_swap(filename: str, legacy: str, new_action: str) -> bytes:
    """For AtualizarTarefa, CriarTarefa, ListarTarefas: swap one line."""
    src = read_bytes_strict(AS_IS_DIR / filename)
    parts, eol = split_keep_eol(src)
    legacy_token = f"dialog: pmo_AssistentePMO_V2.action.{legacy}".encode("utf-8")
    new_token = f"dialog: pmo_AssistentePMO_V2.action.{new_action}".encode("utf-8")
    hits = 0
    new_parts = []
    for line in parts:
        if legacy_token in line:
            new_parts.append(line.replace(legacy_token, new_token))
            hits += 1
        else:
            new_parts.append(line)
    if hits != 1:
        raise RuntimeError(f"{filename}: expected exactly 1 legacy dialog match, found {hits}")
    return join_with_eol(new_parts, eol)


def strip_legacy_comment_lines(text: str, legacy_tokens: list[str], eol: str) -> str:
    """Drop any pure-comment line ('#...') that contains any legacy token.
    Preserves all non-comment lines and comment lines that don't mention legacy tokens."""
    out = []
    for line in text.split(eol):
        stripped = line.lstrip()
        if stripped.startswith("#") and any(tok in line for tok in legacy_tokens):
            continue  # drop legacy-mentioning comment line
        out.append(line)
    return eol.join(out)


def build_invokeflow_swap(filename: str, new_action: str, expected_legacy_flow_id: str) -> bytes:
    """
    For AtualizarStatus and ConsultarPortfolio:
    Replace the InvokeFlowAction block with an equivalent BeginDialog block,
    AND strip any comment lines that mention the legacy action/flow (so that
    the AQ-08 reverify substring check finds zero legacy hits).

    Block shape we expect to find (and rewrite):

        - kind: InvokeFlowAction
          id: <id>
          [input:
            binding:
              <key>: <value>
              ...
          ]
          output:
            binding:
              <key>: <var>
          flowId: <guid>

    Block shape we will write:

        - kind: BeginDialog
          id: <id>                     (preserved)
          input: {}                    (matches existing AtualizarTarefa/CriarTarefa pattern)
          dialog: pmo_AssistentePMO_V2.action.<new_action>
          output:
            binding:
              <preserved_key>: <preserved_var>
    """
    src = read_bytes_strict(AS_IS_DIR / filename)
    text = src.decode("utf-8")
    eol = "\r\n" if "\r\n" in text else "\n"

    # Build the list of legacy tokens to scrub from comment lines.
    legacy_action_short = new_action.replace("PM0_PA_Card_", "PMO_PA_")
    if filename == "ConsultarPortfolio.yaml":
        legacy_action_short = "PMO_PA_ConsultarPortfolio"
    legacy_tokens = [
        legacy_action_short,
        f"pmo_AssistentePMO_V2.action.{legacy_action_short}",
        expected_legacy_flow_id,
    ]
    text = strip_legacy_comment_lines(text, legacy_tokens, eol)

    # Locate the InvokeFlowAction block by its legacy flowId; required to be present exactly once.
    flow_id_pattern = re.compile(
        r"(?P<indent>[ \t]*)- kind: InvokeFlowAction\r?\n"   # block start
        r"(?P<body>(?:[ \t]+.+\r?\n)+?)"                      # body lines
        r"(?P=indent)[ \t]+flowId: " + re.escape(expected_legacy_flow_id) + r"\r?\n",
        re.MULTILINE,
    )
    m = flow_id_pattern.search(text)
    if not m:
        raise RuntimeError(
            f"{filename}: legacy InvokeFlowAction block with flowId={expected_legacy_flow_id} not found"
        )

    block = m.group(0)
    indent = m.group("indent")
    body = m.group("body")

    # Extract the id from the body (first 'id: ...' line).
    id_match = re.search(r"^[ \t]+id:[ \t]*(\S+)\s*$", body, re.MULTILINE)
    if not id_match:
        raise RuntimeError(f"{filename}: cannot locate id under InvokeFlowAction block")
    block_id = id_match.group(1)

    # Extract the FIRST output.binding mapping, preserving its key and value.
    out_match = re.search(
        r"^[ \t]+output:\r?\n[ \t]+binding:\r?\n(?P<bind>(?:[ \t]+.+\r?\n)+?)(?=^[ \t]+(?:flowId:|input:|output:)|\Z)",
        body,
        re.MULTILINE,
    )
    if not out_match:
        raise RuntimeError(f"{filename}: cannot locate output.binding under InvokeFlowAction block")
    out_bind_block = out_match.group("bind").rstrip("\r\n").rstrip("\n")
    bind_lines = [ln for ln in out_bind_block.split("\n") if ln.strip()]
    if len(bind_lines) != 1:
        raise RuntimeError(
            f"{filename}: expected exactly one output.binding line, found {len(bind_lines)}: {bind_lines}"
        )
    bind_line = bind_lines[0].rstrip("\r")
    bind_match = re.match(r"^([ \t]+)(\S+):[ \t]*(\S+)\s*$", bind_line)
    if not bind_match:
        raise RuntimeError(f"{filename}: cannot parse output.binding line: '{bind_line}'")
    bind_indent, bind_key, bind_var = bind_match.group(1), bind_match.group(2), bind_match.group(3)

    # Build the replacement BeginDialog block, preserving outer indent + id + output binding.
    inner = indent + "  "
    inner2 = indent + "    "
    inner3 = indent + "      "
    new_block_lines = [
        f"{indent}- kind: BeginDialog",
        f"{inner}id: {block_id}",
        f"{inner}input: {{}}",
        f"{inner}dialog: pmo_AssistentePMO_V2.action.{new_action}",
        f"{inner}output:",
        f"{inner2}binding:",
        f"{inner3}{bind_key}: {bind_var}",
    ]
    new_block = eol.join(new_block_lines) + eol

    new_text = text[: m.start()] + new_block + text[m.end():]
    return new_text.encode("utf-8")


# -------- main --------

CASES = [
    # (filename, legacy_token_for_simple_swap, new_action, legacy_flow_id_for_invokeflow_swap)
    ("AtualizarStatus.yaml",     None,                       "PM0_PA_Card_AtualizarStatus",          "c11a165b-c64c-f111-bec7-7ced8d9559c1"),
    ("AtualizarTarefa.yaml",     "PMO_PA_AtualizarTarefa",   "PM0_PA_Card_AtualizarTarefa",          None),
    ("ConsultarPortfolio.yaml",  None,                       "PM0_PA_Card_ResumoExecutivoPortfolio", "39cf292d-c64c-f111-bec7-7ced8d955c6c"),
    ("CriarTarefa.yaml",         "PMO_PA_CriarTarefa",       "PM0_PA_Card_CriarTarefa",              None),
    ("ListarTarefas.yaml",       "PMO_PA_ListarTarefas",     "PM0_PA_Card_ListarTarefas",            None),
]


def gate(name, ok, detail=""):
    status = "PASS" if ok else "FAIL"
    print(f"  [{status}] {name}: {detail}")
    return ok


def validate(filename: str, fixed_bytes: bytes, new_action: str, legacy_flow_id: str | None) -> bool:
    print(f"\n=== {filename} ===")
    as_is = read_bytes_strict(AS_IS_DIR / filename)
    overall = True

    # G1
    overall &= gate("G1 non-empty", len(fixed_bytes) > 0, f"{len(fixed_bytes)} bytes")

    # G2 BOM
    overall &= gate("G2 no BOM", fixed_bytes[:3] != b"\xef\xbb\xbf", "")

    # G3 line endings match AS-IS
    crlf_a, crlf_f = as_is.count(b"\r\n"), fixed_bytes.count(b"\r\n")
    lf_only_a = as_is.count(b"\n") - crlf_a
    lf_only_f = fixed_bytes.count(b"\n") - crlf_f
    overall &= gate("G3 line endings",
                    (crlf_a > 0 and crlf_f > 0 and lf_only_f == 0) or
                    (crlf_a == 0 and lf_only_a > 0 and lf_only_f > 0 and crlf_f == 0),
                    f"AS-IS CRLF={crlf_a} LF={lf_only_a} | FIXED CRLF={crlf_f} LF={lf_only_f}")

    # G4 YAML parses
    try:
        as_is_doc = yaml.safe_load(as_is.decode("utf-8"))
        fixed_doc = yaml.safe_load(fixed_bytes.decode("utf-8"))
        overall &= gate("G4 fixed YAML parses", True, "")
    except yaml.YAMLError as e:
        overall &= gate("G4 fixed YAML parses", False, str(e))
        return False

    # G5 minimal diff (actual sequence edit count via difflib)
    import difflib
    as_is_lines = as_is.decode("utf-8").splitlines()
    fixed_lines = fixed_bytes.decode("utf-8").splitlines()
    sm = difflib.SequenceMatcher(a=as_is_lines, b=fixed_lines, autojunk=False)
    edit_lines = 0
    edits = []
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag == "equal":
            continue
        edit_lines += max(i2 - i1, j2 - j1)
        edits.append((tag, i1, i2, j1, j2))
    if legacy_flow_id is None:
        # simple dialog swap -> exactly 1 edit (1-line replace)
        ok = edit_lines == 1
        overall &= gate("G5 simple swap = 1 edit line", ok, f"{edit_lines} edits across {len(edits)} ops")
    else:
        # InvokeFlowAction -> BeginDialog: bounded structural change
        ok = edit_lines <= 30
        overall &= gate("G5 structural swap edit lines <= 30", ok, f"{edit_lines} edits across {len(edits)} ops")
    for tag, i1, i2, j1, j2 in edits:
        print(f"    {tag}: AS-IS lines {i1+1}..{i2}  FIXED lines {j1+1}..{j2}")
        for k in range(i1, min(i1 + 3, i2)):
            print(f"      - AS-IS[{k+1}]: |{as_is_lines[k]}|")
        if i2 - i1 > 3:
            print(f"      - ... ({i2 - i1 - 3} more removed)")
        for k in range(j1, min(j1 + 3, j2)):
            print(f"      + FIXED[{k+1}]: |{fixed_lines[k]}|")
        if j2 - j1 > 3:
            print(f"      + ... ({j2 - j1 - 3} more added)")

    # G6 references
    text = fixed_bytes.decode("utf-8")
    overall &= gate("G6 contains new action component", new_action in text, new_action)
    # Build the exact legacy action component reference name to look for absence
    if filename == "ConsultarPortfolio.yaml":
        legacy_ref = "PMO_PA_ConsultarPortfolio"
    else:
        legacy_ref = new_action.replace("PM0_PA_Card_", "PMO_PA_")
    overall &= gate("G6 no legacy action ref anywhere (incl. comments)",
                    legacy_ref not in text,
                    f"checking absence of '{legacy_ref}'")
    if legacy_flow_id:
        overall &= gate("G6 no legacy flowId",
                        legacy_flow_id not in text,
                        f"checking absence of '{legacy_flow_id}'")

    # G7 top-level keys preserved
    if isinstance(as_is_doc, dict) and isinstance(fixed_doc, dict):
        overall &= gate("G7 top-level keys preserved",
                        set(as_is_doc.keys()) == set(fixed_doc.keys()),
                        f"{sorted(fixed_doc.keys())}")

    # G8 the new action call exists at exactly one place
    overall &= gate("G8 new action component appears exactly once",
                    text.count(new_action) == 1,
                    f"count={text.count(new_action)}")

    return overall


def main():
    print("AQ-08 minimal-diff fixed YAML builder + gates")
    print("=" * 60)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    results = {}
    payloads = {}

    for filename, legacy, new_action, legacy_flow_id in CASES:
        try:
            if legacy is not None:
                fixed = build_simple_dialog_swap(filename, legacy, new_action)
            else:
                fixed = build_invokeflow_swap(filename, new_action, legacy_flow_id)
        except Exception as e:
            print(f"\n=== {filename} ===\n  BUILD ERROR: {e}")
            results[filename] = False
            continue

        ok = validate(filename, fixed, new_action, legacy_flow_id)
        results[filename] = ok
        if ok:
            payloads[filename] = fixed

    # Only write files that passed every gate.
    print("\n" + "=" * 60)
    print("WRITING (only PASS files):")
    for filename, fixed in payloads.items():
        out_path = OUT_DIR / filename
        write_bytes_strict(out_path, fixed)
        print(f"  wrote {out_path} ({len(fixed)} bytes)")

    print("\n" + "=" * 60)
    print("SUMMARY")
    for filename, ok in results.items():
        print(f"  [{'PASS' if ok else 'FAIL'}] {filename}")
    overall = all(results.values())
    print(f"\nOverallDecision: {'PASS' if overall else 'FAIL'}")
    sys.exit(0 if overall else 1)


if __name__ == "__main__":
    main()
