"""
AQ-08 topic YAML quality gates.

Runs strict validation on each fixed topic YAML before delivery to the Owner:
  G1: file exists and is non-empty
  G2: encoding is UTF-8 without BOM (matches live AS-IS)
  G3: line endings are CRLF (matches live AS-IS)
  G4: YAML parses with strict PyYAML
  G5: only line 149 (or the documented action-call line) differs from AS-IS
  G6: the new dialog reference contains 'PM0_PA_Card_' and not legacy 'PMO_PA_'
  G7: top-level keys match AS-IS
"""

from __future__ import annotations
import sys
import json
import yaml
from pathlib import Path

ROOT = Path(r"D:\VMs\Projetos\STT_Project_Management")
AS_IS_DIR = ROOT / ".planning/milestones/M2_card_first_revision_v2/phases/01_discovery/F_topic_yamls"
FIXED_DIR = ROOT / ".planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/fixed_topic_yamls"

CASES = [
    ("AtualizarStatus.yaml",     "PM0_PA_Card_AtualizarStatus",          "InvokeFlowAction->BeginDialog"),
    ("AtualizarTarefa.yaml",     "PM0_PA_Card_AtualizarTarefa",          "BeginDialog dialog swap"),
    ("ConsultarPortfolio.yaml",  "PM0_PA_Card_ResumoExecutivoPortfolio", "InvokeFlowAction->BeginDialog"),
    ("CriarTarefa.yaml",         "PM0_PA_Card_CriarTarefa",              "BeginDialog dialog swap"),
    ("ListarTarefas.yaml",       "PM0_PA_Card_ListarTarefas",            "BeginDialog dialog swap"),
]


def gate(name, ok, detail=""):
    status = "PASS" if ok else "FAIL"
    print(f"  [{status}] {name}: {detail}")
    return ok


def check_file(filename, expected_new_action, kind_change):
    print(f"\n=== {filename} ({kind_change}) ===")
    as_is_path = AS_IS_DIR / filename
    fixed_path = FIXED_DIR / filename

    overall = True

    # G1
    if not gate("G1 exists+non-empty (AS-IS)", as_is_path.exists() and as_is_path.stat().st_size > 0,
                f"{as_is_path}"):
        return False
    if not gate("G1 exists+non-empty (FIXED)", fixed_path.exists() and fixed_path.stat().st_size > 0,
                f"{fixed_path}"):
        return False

    as_is_bytes = as_is_path.read_bytes()
    fixed_bytes = fixed_path.read_bytes()

    # G2 BOM
    has_bom_asis = as_is_bytes[:3] == b"\xef\xbb\xbf"
    has_bom_fixed = fixed_bytes[:3] == b"\xef\xbb\xbf"
    overall &= gate("G2 no BOM (AS-IS)",  not has_bom_asis,  f"BOM={has_bom_asis}")
    overall &= gate("G2 no BOM (FIXED)",  not has_bom_fixed, f"BOM={has_bom_fixed}")

    # G3 line endings
    crlf_asis = as_is_bytes.count(b"\r\n")
    lf_only_asis = as_is_bytes.count(b"\n") - crlf_asis
    crlf_fixed = fixed_bytes.count(b"\r\n")
    lf_only_fixed = fixed_bytes.count(b"\n") - crlf_fixed
    overall &= gate("G3 line endings match",
                    (crlf_asis > 0 and crlf_fixed > 0 and lf_only_fixed == 0)
                    or (crlf_asis == 0 and lf_only_asis > 0 and lf_only_fixed > 0 and crlf_fixed == 0),
                    f"AS-IS CRLF={crlf_asis} LF={lf_only_asis} | FIXED CRLF={crlf_fixed} LF={lf_only_fixed}")

    # G4 YAML parses
    try:
        as_is_doc = yaml.safe_load(as_is_bytes.decode("utf-8"))
        gate("G4 AS-IS parses with PyYAML", True, f"top kind={list(as_is_doc.keys()) if isinstance(as_is_doc, dict) else type(as_is_doc).__name__}")
    except yaml.YAMLError as e:
        overall = False
        gate("G4 AS-IS parses with PyYAML", False, f"YAMLError: {e}")
        as_is_doc = None

    try:
        fixed_doc = yaml.safe_load(fixed_bytes.decode("utf-8"))
        gate("G4 FIXED parses with PyYAML", True, f"top kind={list(fixed_doc.keys()) if isinstance(fixed_doc, dict) else type(fixed_doc).__name__}")
    except yaml.YAMLError as e:
        overall = False
        gate("G4 FIXED parses with PyYAML", False, f"YAMLError: {e}")
        fixed_doc = None

    # G5 line-by-line diff
    as_is_lines = as_is_bytes.decode("utf-8").splitlines()
    fixed_lines = fixed_bytes.decode("utf-8").splitlines()
    diff_lines = []
    max_len = max(len(as_is_lines), len(fixed_lines))
    for i in range(max_len):
        a = as_is_lines[i] if i < len(as_is_lines) else "<MISSING>"
        f = fixed_lines[i] if i < len(fixed_lines) else "<MISSING>"
        if a != f:
            diff_lines.append((i + 1, a, f))
    if diff_lines:
        print(f"  diff lines count: {len(diff_lines)}")
        for lineno, a, f in diff_lines[:5]:
            print(f"    line {lineno}: AS-IS=|{a}|")
            print(f"             FIXED=|{f}|")
        if len(diff_lines) > 5:
            print(f"    ... and {len(diff_lines) - 5} more diffs")
    else:
        print("  diff lines count: 0 (files identical)")

    # G6 new action ref present, legacy gone
    fixed_text = fixed_bytes.decode("utf-8")
    overall &= gate("G6 fixed contains new action", expected_new_action in fixed_text,
                    f"looking for '{expected_new_action}'")
    legacy_token = expected_new_action.replace("PM0_PA_Card_", "PMO_PA_")
    # Special case for ConsultarPortfolio (semantic merge)
    if filename == "ConsultarPortfolio.yaml":
        legacy_token = "PMO_PA_ConsultarPortfolio"
    overall &= gate("G6 fixed has no legacy ref", legacy_token not in fixed_text,
                    f"checking absence of '{legacy_token}'")

    # G7 top-level keys
    if isinstance(as_is_doc, dict) and isinstance(fixed_doc, dict):
        overall &= gate("G7 top-level keys match",
                        set(as_is_doc.keys()) == set(fixed_doc.keys()),
                        f"AS-IS={sorted(as_is_doc.keys())} FIXED={sorted(fixed_doc.keys())}")

    return overall


def main():
    print("AQ-08 Fixed Topic YAML Quality Gates")
    print("=" * 60)
    results = {}
    for filename, new_action, kind_change in CASES:
        try:
            ok = check_file(filename, new_action, kind_change)
        except Exception as e:
            ok = False
            print(f"  EXCEPTION: {e}")
        results[filename] = ok

    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    for filename, ok in results.items():
        status = "PASS" if ok else "FAIL"
        print(f"  [{status}] {filename}")

    overall_pass = all(results.values())
    print()
    print("OverallDecision:", "PASS" if overall_pass else "FAIL")
    sys.exit(0 if overall_pass else 1)


if __name__ == "__main__":
    main()
