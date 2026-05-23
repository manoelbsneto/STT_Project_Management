# AQ-08 Publish Drift Monitor Dispatch

- publish_utc_label: `2026-05-22T11:15:52.9307207+00:00`
- background_launch_brt: `2026-05-22 08:23:24 -03:00`
- background_launch_utc: `2026-05-22 11:23:24 +00:00`
- launch_method: `Start-Process powershell.exe -WindowStyle Hidden`
- execution_shell: `Windows PowerShell 5.1`
- process_id: `44496`
- process_state_at_dispatch_check: `running`
- output_dir: `D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq08_topic_routing_verification_20260520\post_publish_verify\drift_monitoring_20260522_0816`

## Dispatch outputs

- monitor_stdout: `drift_monitor_stdout.json`
- monitor_stderr: `drift_monitor_stderr.txt`
- expected_final_decision: `DRIFT_DECISION.md`
- scheduled_pass_dirs: `T+5min`, `T+1h`, `T+6h`

## Gate timing

`tests/Test-Aq08PublishDriftMonitor.ps1` schedules T+5min, T+1h, and T+6h from monitor invocation time. `-PublishUtc` labels the evidence and checks that the publish window was not missed; it does not set the scheduling baseline.

- expected_t_plus_6h_gate_brt: `2026-05-22 14:23:24 -03:00`
- expected_t_plus_6h_gate_utc: `2026-05-22 17:23:24 +00:00`

## Safety

- The monitor delegates each pass to `tests/Test-Aq08PostRemediationReverify.ps1`.
- The delegated live path uses PAC read-only inventory operations only.
