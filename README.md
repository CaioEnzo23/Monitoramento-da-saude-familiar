Com certeza. Com base nos arquivos de código-fonte e no banner do projeto que você forneceu, aqui está um `README.md` completo e estruturado.

-----

# Monitoramento da Saúde Familiar

## 🏁 Status do Projeto

[cite\_start]**Concluído.** O aplicativo foi validado como funcional, estável e fácil de usar[cite: 9].

-----

## Tabela de Conteúdos

  * [Descrição do Projeto](https://www.google.com/search?q=%23descri%C3%A7%C3%A3o-do-projeto)
  * [Funcionalidades Principais](https://www.google.com/search?q=%23funcionalidades-principais)
  * [Telas do App](https://www.google.com/search?q=%23telas-do-app)
  * [Tecnologias Utilizadas](https://www.google.com/search?q=%23tecnologias-utilizadas)
  * [Contexto Acadêmico](https://www.google.com/search?q=%23contexto-acad%C3%AAmico)
  * [Equipe e Orientador](https://www.google.com/search?q=%23equipe-e-orientador)
  * [Como Executar o Projeto](https://www.google.com/search?q=%23como-executar-o-projeto)

-----

## 📜 Descrição do Projeto

[cite\_start]Cuidar da saúde de quem amamos é uma prioridade, mas na correria do dia a dia, acompanhar de perto indicadores como glicemia, pressão arterial e oxigenação pode ser um verdadeiro desafio[cite: 17]. [cite\_start]Muitas famílias que lidam com condições crônicas acabam com medições importantes anotadas em papéis ou perdidas em notas de celular [cite: 18][cite\_start], sem conseguir visualizar o histórico completo ou perceber tendências[cite: 17, 18].

[cite\_start]Diante dessa dificuldade, o "Monitoramento da Saúde Familiar" foi criado como uma ferramenta digital acessível e intuitiva[cite: 20, 21]. [cite\_start]O objetivo é trazer mais tranquilidade ao cuidador, permitindo o gerenciamento de múltiplos perfis em um só lugar, facilitando o registro constante das métricas de saúde e, o mais importante, transformando dados brutos em informações visuais claras[cite: 21, 22].

-----

## 🚀 Funcionalidades Principais

  * [cite\_start]**Gerenciamento de Múltiplos Perfis:** Permite cadastrar [cite: 10] e alternar entre diferentes perfis de familiares (com nome, idade, peso e altura) através de um carrossel.
  * **Registro de Métricas:** Facilita o registro de um conjunto completo de métricas de saúde, incluindo 'Glicemia em Jejum', 'Glicemia Pós Brandial', 'Pressão Arterial', 'Oxigenação e Pulso', 'Temperatura', 'Peso' e 'Altura'.
  * **Agendamento e Rotinas:** Permite agendar métricas com diferentes constâncias: 'Única', 'Diária', 'Semanal', 'Mensal' ou em 'Dias específicos'.
  * **Lembretes e Notificações:** Agenda notificações locais para lembrar o usuário o horário de registrar uma medição.
  * **Dashboards Visuais:** Ao selecionar uma métrica, o usuário é levado a uma tela de gráfico detalhada (`Dash_page`).
  * **Gráficos de Histórico:** Exibe a evolução das medições ao longo do tempo em um gráfico de linha (`LineChart`), com um seletor para navegar entre os meses.
  * **Resumo de Classificação:** Apresenta um gráfico de barras (`BarChart`) que resume a quantidade de registros classificados como 'Baixo', 'Normal' ou 'Alto'.
  * **Medidores de Risco:** Mostra a medição mais recente em um medidor visual (`SfRadialGauge`) com faixas de cor que indicam o nível de risco.
  * **Lógica Dupla:** O sistema é capaz de lidar com métricas de valor único (como Temperatura) e valor duplo (como 'Pressão Arterial' e 'Oxigenação e Pulso') nos gráficos e medidores.
  * **Armazenamento Local:** Utiliza o banco de dados `Hive` para persistir todos os perfis e métricas de forma leve e rápida no dispositivo.

-----

## 📱 Telas do App

[cite\_start]O aplicativo é composto por duas telas principais, conforme visto nos arquivos de código e no banner[cite: 25]:

### 1\. Home (`Home_page.dart`)

É a tela principal do aplicativo. Nela, o usuário pode:

  * Alternar entre os perfis cadastrados no carrossel superior.
  * Selecionar um dia específico no calendário.
  * Ver a lista de métricas agendadas para aquele dia.
  * Adicionar novas métricas e agendamentos usando o botão flutuante.
  * Navegar para a tela de gráfico clicando em um item da lista.

### 2\. Dashboard (`Dash_page.dart`)

Esta tela é aberta ao selecionar uma métrica e exibe:

  * O título "Gráfico de [Nome da Métrica]".
  * Um gráfico de linha com o "Histórico" da métrica, navegável por mês.
  * Um gráfico de barras com o "Resumo de Classificação" (Baixo, Normal, Alto).
  * Um ou dois "Medidores da Última Métrica" para a medição mais recente.

-----

## 🛠️ Tecnologias Utilizadas

  * [cite\_start]**Flutter e Dart:** Framework e linguagem principal para o desenvolvimento[cite: 13].
  * **Hive:** Banco de dados NoSQL local, leve e rápido, usado para todo o armazenamento de perfis e métricas.
  * **`fl_chart`:** Biblioteca para a criação dos gráficos de linha e de barra na tela de dashboard.
  * **`syncfusion_flutter_gauges`:** Biblioteca para a criação dos medidores (gauges) de risco.
  * **`flutter_local_notifications`:** Utilizada para agendar e disparar os lembretes de medição.

-----

## 🎓 Contexto Acadêmico

[cite\_start]Este projeto foi desenvolvido para o **IV Simpósio de Disciplinas Extensionistas** do **Centro Universitário Estácio Ceará**, Campus Parangaba[cite: 2, 24].

  * [cite\_start]**Curso:** Ciências da Computação e Análise e Desenvolvimento de Sistemas[cite: 7].
  * [cite\_start]**Disciplina:** ARA0089 – Programação para Dispositivos Móveis em Android[cite: 4].

-----

## 👨‍💻 Equipe e Orientador

### Equipe 7

  * [cite\_start]Kauan Bezerra Monteiro [cite: 5]
  * [cite\_start]João Gonçalves Neto [cite: 5]
  * [cite\_start]Caio Enzo de Menezes Vieira [cite: 5]
  * [cite\_start]Edson Fernando Araujo Silva [cite: 5]

### Orientador

  * [cite\_start]Juciarias Nascimento [cite: 6]

-----

## ⚙️ Como Executar o Projeto

1.  **Pré-requisitos:**

      * Ter o [SDK do Flutter](https://flutter.dev/docs/get-started/install) instalado.
      * Ter um emulador Android/iOS ou um dispositivo físico conectado.

2.  **Clonar o Repositório:**

    ```bash
    git clone https://github.com/seu-usuario/nome-do-repositorio.git
    cd nome-do-repositorio
    ```

3.  **Instalar Dependências:**

    ```bash
    flutter pub get
    ```

4.  **Executar o Aplicativo:**

    ```bash
    flutter run
    ```
