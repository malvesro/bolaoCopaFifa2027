# Tasks

## 1. Preparar o ponto de entrada e o inventário documental

- [x] 1.1 Reescrever `CLAUDE.md` como índice curto com precedência em um único local, links relativos por tipo de tarefa, distinção entre instruções automáticas e documentos consultados sob demanda, preservando invariantes críticas; validar todos os destinos e comparar as regras resumidas com requisito v3.2 e `decisoes-pendentes.md`.
- [x] 1.2 Inventariar referências e conteúdo exclusivo do prompt arquitetural histórico; decidir entre remoção e retenção com aviso não operacional, atualizar referências dependentes e verificar que nenhuma regra/decisão aprovada fique sem fonte canônica.

## 2. Corrigir e consolidar documentação especializada

- [x] 2.1 Corrigir na arquitetura repetições ou status imprecisos de regras já definidas, mantendo mecanismos não decididos como recomendações/pendências e sem alterar conteúdo normativo; verificar as passagens afetadas contra requisito v3.2 e decisões pendentes.
- [x] 2.2 Qualificar no relatório multiagentes as observações dependentes do snapshot do repositório e corrigir referências obsoletas; confirmar que conclusões de arquitetura continuam claramente não normativas.
- [x] 2.3 Corrigir links e referências editoriais identificados em PROD-06 e nos demais documentos incluídos, mantendo explícito que critérios de badges aguardam aprovação; verificar destinos internos e rótulos Markdown.
- [x] 2.4 Criar `docs/architecture/plano-reestruturacao-documentacao.md` com diagnóstico, justificativa, destino/proveniência de conteúdo, arquivos retidos/removidos e registro das mudanças efetivamente executadas; conferir cada afirmação com o diff final.

## 3. Verificação integrada documental

- [x] 3.1 Executar verificações locais de links relativos e caminhos mencionados nos Markdown relevantes, corrigir os inválidos dentro do escopo e confirmar que todas as fontes citadas existem.
- [x] 3.2 Revisar o diff e `git status`; comparar invariantes aprovadas (pontuação, placar de 120 minutos, corte/reabertura/privacidade, ranking, BRT, grupo único, escopo e status PROD-06) antes/depois; validar OpenSpec e confirmar que configuração, código e arquivos não rastreados alheios permaneceram intactos.