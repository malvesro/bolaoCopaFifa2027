# Design

## Context

Consulte `proposal.md` para motivação e escopo. A auditoria encontrou sete documentos-base versionados, sem aplicação ou comandos de validação documental dedicados. `CLAUDE.md` é o ponto de entrada automático do Claude Code; os documentos especializados são consultados sob demanda. OpenSpec está configurado como `spec-driven`, sem specs existentes; por não haver mudança de comportamento, esta mudança usa `skip_specs: true` e não tocará a configuração.

## Goals / Non-Goals

**Goals:**
- Manter uma fonte normativa identificável para cada regra e decisão, com apontadores nos documentos consumidores.
- Reduzir contexto obsoleto e repetido sem perder conteúdo válido, proveniência ou ressalvas de aprovação.
- Decidir remoções usando rastreabilidade de conteúdo, referências e histórico, registrando a justificativa no plano documental.

**Non-Goals:**
- Alterar requisitos de produto, decisões aprovadas, direções técnicas ou regras OpenSpec.
- Reorganizar/incluir/excluir árvores de integração de agentes não rastreadas, criar ADRs, novas instruções por diretório, novos manuais de execução ou specs de comportamento.
- Alterar código, configuração executável ou infraestrutura.

## Decisions

1. **`CLAUDE.md` como índice, não como cópia da documentação.** Conservar apenas contexto essencial, precedência, stack/direção definida, invariantes críticas resumidas, gates de segurança/SDD e mapa com links para leitura necessária. A redução deve manter explicitamente as regras temporais e de privacidade mais críticas, remetendo aos requisitos v3.2 para texto normativo completo. Isso melhora recuperação sem depender de o agente inferir que um link carrega automaticamente o conteúdo.

2. **Separar estados factuais de recomendações.** Na arquitetura, apresentar claramente restrições definidas, decisões formalmente aprovadas, recomendações ainda não aprovadas e pendências. Corrigir formulações que chamem de pendente comportamento já decidido, mantendo os detalhes técnicos realmente em aberto e as propostas identificadas como propostas. Na revisão multiagentes, datar/qualificar observações de estado volátil, como Git e arquivos não rastreados.

3. **Tratar o prompt arquitetural como histórico ou removê-lo após análise de proveniência.** Antes de qualquer exclusão, verificar todas as referências, preservar a informação de origem ainda necessária em material vigente, corrigir referências inválidas onde o prompt continuar referenciado e assegurar que regras/decisões não tenham fonte exclusiva ali. Se não houver necessidade de consulta operacional ou histórica além do histórico Git, remover o prompt e registrar a justificativa. Se remover contrariar retenção/proveniência, mantê-lo com aviso destacado de não operacional e corrigir o caminho quebrado. Não converter suas instruções obsoletas em política atual.

4. **Correções locais e semânticas mínimas.** Reparar links legíveis e referências a caminhos, corrigir typos e reduzir repetição normativa apenas onde o destino canônico estiver explícito. Não reescrever a proposta PROD-06 de modo que pareça aprovada; melhorias de link/legibilidade são permitidas, mas manter nela a ressalva e a referência à versão do requisito.

5. **Sem fragmentação por tamanho isolado.** Não dividir o documento de arquitetura nem a especificação de badges nesta mudança: a auditoria não demonstrou que novos arquivos especializados tragam benefício suficiente para compensar a navegação e o risco de dispersão. O plano de implementação atual permanece no documento de arquitetura salvo evidência concreta de que precisa de fonte independente.

6. **OpenSpec só como trilha de planejamento.** Usar os artefatos deste change como plano rastreável; declarar ausência de delta comportamental via `skip_specs: true`. Não criar capability/spec artificial, não mudar `openspec/config.yaml`, não sincronizar ou arquivar durante o planejamento.

## Risks / Trade-offs

- [Reduzir duplicação pode remover um lembrete útil de uma regra crítica] → manter resumo de segurança/tempo no ponto de uso e validar contra requisitos v3.2 e decisões canônicas antes/depois.
- [Remover prompt pode eliminar proveniência acessível fora do Git] → auditar referências e conteúdo exclusivo, preservar origem nos documentos atuais e registrar decisão; preferir manter com sinalização se houver uso histórico legítimo.
- [Ajustes em documento de auditoria podem desatualizar conclusões ou atribuir fatos ao presente] → qualificar data/escopo observado e não alterar conclusões técnicas fora do escopo documental.
- [Links externos podem estar indisponíveis] → validar sintaxe/rótulo e links internos localmente; declarar separadamente se disponibilidade HTTP não for verificada.

## Migration Plan

1. Aplicar mudanças documentais pequenas e preservar o estado pré-existente da working tree, inclusive arquivos não rastreados.
2. Atualizar referências e status após decidir retenção do prompt; conferir cada destino interno.
3. Criar o plano com problemas, mudança, destino, benefício, riscos, decisão de retenção e mudanças realmente executadas.
4. Comparar os pontos normativos críticos antes/depois com requisito v3.2, decisões pendentes e estado de aprovação PROD-06.
5. Validar links relativos, caminhos mencionados e coerência OpenSpec; revisar diff e `git status` para provar que somente o escopo aprovado foi tocado.

Rollback: reverter somente os arquivos documentais desta mudança se surgir perda de conteúdo ou interpretação ambígua; não tocar na configuração OpenSpec nem em artefatos pré-existentes não relacionados.

## Open Questions

Nenhuma decisão de produto está aberta para esta alteração. A retenção do prompt legado será decidida durante a execução por critérios verificáveis de uso, referências e preservação de proveniência descritos acima; caso não seja possível determinar com segurança se sua remoção descarta conteúdo válido necessário, mantê-lo sinalizado em vez de apagar.