# QA Evidence - 3.15.1 Hotfix Topics Phase B

Date BRT: 2026-05-21

Artifact: `Solution/PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip`
OverallDecision: **PASS**

| Gate | Status | Evidence |
|---|---|---|
| G1 | PASS | zipEntries=60; xml=True; workflowRoots=12; workflowFiles=12; topicRoots=5; topicDataFiles=5 |
| G2 | PASS | workflowFilesCompared=12; mismatches=0 |
| G3 | PASS | topicDataFilesCompared=5; mismatches=0 |
| G4 | PASS | manifestTopicIds=5; expectedTopicIds=5; ids=6750ff2f-822b-45ab-83ec-058704c7808a,74c5fdcc-c121-452e-85af-24d3f260b3c7,bcbecd76-3158-40ac-b225-5ae7c3874ed1,d58258b4-b17f-4bb9-9e1f-161287a041c4,ec4416d0-0744-4e8c-b937-aae4ad9c605b |
| G5 | PASS | topicsChecked=5; invalidBindingKeys=0 |
| G6 | PASS | topicsChecked=5; mismatches=0; AtualizarStatus:binding=AtualizarStatusResult;sendRefs=AtualizarStatusResult; AtualizarTarefa:binding=message;sendRefs=; ConsultarPortfolio:binding=ConsultarPortfolioResult;sendRefs=ConsultarPortfolioResult; CriarTarefa:binding=Result;sendRefs=Result; ListarTarefas:binding=tarefas;sendRefs= |
| G7 | PASS | topicsChecked=5; legacyTopicRefs=0 |
| G8 | PASS | topicsChecked=5; nonAsciiTopics=0 |
| G9 | PASS | topicsChecked=5; expectedActions=PM0_PA_Card_AtualizarStatus,PM0_PA_Card_AtualizarTarefa,PM0_PA_Card_ResumoExecutivoPortfolio,PM0_PA_Card_CriarTarefa,PM0_PA_Card_ListarTarefas; unexpected=0; missing=0 |

## Stop Rule

All Phase B gates completed.

## Inputs

- Hotfix ZIP: `D:\VMs\Projetos\STT_Project_Management\Solution\PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip`
- Unpacked hotfix tree: `D:\VMs\Projetos\STT_Project_Management\.planning\comms\solution_3_15_1_hotfix_topics_20260521\build\unpacked_base`
- Base 3.15 unpacked tree: `D:\VMs\Projetos\STT_Project_Management\.planning\comms\solution_3_15_list_static_runtime_bypass_20260514\unpacked`
- Fixed topic YAMLs: `D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq08_topic_routing_verification_20260520\post_remediation_reverify\fixed_topic_yamls`
