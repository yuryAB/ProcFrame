# Plano de Ação 1 — Modularização com Clean Architecture (sem novas features)

Objetivo: reorganizar o projeto para isolar painéis e camadas, mantendo o comportamento atual intacto.

1) Diagnóstico e inventário
- [x] Mapear dependências atuais dos painéis (`UI/Panels/*`) e do `ContentView.swift`.
- [x] Listar responsabilidades de cada manager/estado e onde são usados.

2) Definir módulos/camadas
- [x] Criar estrutura base: `Domain/`, `Presentation/`, `Data/`, mantendo `UI/`.
- [x] Definir contratos (protocolos) em `Domain/` para: seleção de nodes, importação de imagens, timeline, logging.

3) Isolar SpriteKit (adapters)
- [x] Definir portas de entrada/saída para comunicação UI/Domain com SpriteKit.
- [x] Mapear quais chamadas de SpriteKit precisam virar adaptadores.

4) Extrair regras para Domain
- [x] Mover entidades simples e regras sem UI para `Domain/Entities` e `Domain/UseCases`.
- [x] Garantir que `Domain` não importe SwiftUI/AppKit/SpriteKit.

5) Refatorar Managers para Presentation/Data
- [x] ViewModels e estados de UI vão para `Presentation/`.
- [x] Managers que acessam IO/CoreData/Assets vão para `Data/`.
- [x] Substituir uso direto por protocolos do `Domain`.

6) Modularizar painéis
- [x] Para cada painel, criar pasta dedicada com:
  - View
  - ViewModel (Presentation)
  - Protocolos de entrada/saída (Domain)
- [x] Remover acesso direto a SpriteKit/Managers dentro dos Views.

7) Composição de dependências
- [x] Criar Composition Root (ex.: `ProcFrameApp.swift` ou `AppContainer.swift`).
- [x] Instanciar implementações concretas e injetar nos ViewModels.

8) Estabilização
- [x] Build após cada painel migrado (executado via `xcodebuild` com permissões).
- [x] Garantir que a UI continua funcionando igual (sem mudanças visuais/comportamentais).

9) Documentação mínima
- [x] Atualizar `AGENTS.md` conforme a estrutura final.
- [x] Adicionar um mapa simples de dependências (UI -> Presentation -> Domain -> Data).

Critérios de sucesso
- App compila e executa com o mesmo comportamento atual.
- Painéis isolados por pastas e com ViewModels próprios.
- Nenhuma camada viola as dependências de Clean Architecture.
