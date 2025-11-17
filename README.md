# <img width="40" height="40" alt="image" src="https://github.com/user-attachments/assets/6496e9d2-5f2f-4dc5-9d01-8d3891d9f7fb" />  Monitoramento da Saúde Familiar

## 🏁 Status do Projeto

**Concluído.** O aplicativo foi validado como funcional, estável e fácil de usar[cite: 9].

-----

## Tabela de Conteúdos

  * Descrição do Projeto
  * Funcionalidades Principais
  * Telas do App
  * Tecnologias Utilizadas
  * Contexto Acadêmico
  * Equipe e Orientador
  * Como Executar o Projeto

-----

## 📜 Descrição do Projeto

Este projeto tem como objetivo desenvolver uma aplicação móvel acessível e intuitiva para o gerenciamento da saúde familiar , utilizando o framework Flutter e o banco de dados local Hive.

Cuidar da saúde de entes queridos é uma prioridade, mas o acompanhamento diário de indicadores vitais, como glicemia e pressão arterial, representa um desafio logístico. Atualmente, muitas famílias que lidam com condições crônicas registram medições importantes em papéis ou as perdem em notas de celular. Essa falta de organização centralizada gera insegurança e dificulta o gerenciamento proativo do bem-estar familiar.

A transformação de dados brutos em informações visuais claras, como gráficos históricos e medidores de risco, é identificada como um objetivo fundamental para trazer tranquilidade ao cuidador. A validação de funções como o cadastro de múltiplos perfis em um só lugar, o registro de métricas e o agendamento de lembretes é crucial para que a ferramenta seja funcional e fácil de usar no dia a dia.

Neste contexto, o presente projeto, "Monitoramento da Saúde Familiar" , aplica a tecnologia Flutter  para centralizar o registro dessas métricas. A solução oferece dashboards que mostram a evolução da saúde em gráficos, resultados recentes em medidores visuais e resumos de classificação (níveis "Altos" ou "Baixos") , oferecendo um apoio real para quem precisa monitorar e visualizar a saúde de quem ama.

-----

## 🚀 Funcionalidades Principais

  * **Gerenciamento de Múltiplos Perfis:** Permite cadastrar e alternar entre diferentes perfis de familiares (com nome, idade, peso e altura) através de um carrossel.
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

O aplicativo é composto por duas telas principais, conforme visto nos arquivos de código e no banner[cite: 25]:

### 1\. Home (`Home_page.dart`)

É a tela principal do aplicativo. Nela, o usuário pode:

  * Alternar entre os perfis cadastrados no carrossel superior.
  * Selecionar um dia específico no calendário.
  * Ver a lista de métricas agendadas para aquele dia.
  * Adicionar novas métricas e agendamentos usando o botão flutuante.
  * Navegar para a tela de gráfico clicando em um item da lista.

<img width="400" height="900" alt="Image" src="https://github.com/user-attachments/assets/eb24a847-a7d9-4d84-90e8-b2954143a7b4" />

### 2\. Dashboard (`Dash_page.dart`)

Esta tela é aberta ao selecionar uma métrica e exibe:

  * O título "Gráfico de [Nome da Métrica]".
  * Um gráfico de linha com o "Histórico" da métrica, navegável por mês.
  * Um gráfico de barras com o "Resumo de Classificação" (Baixo, Normal, Alto).
  * Um ou dois "Medidores da Última Métrica" para a medição mais recente.

<img width="400" height="900" alt="Image" src="https://github.com/user-attachments/assets/ffae3cae-9bff-4390-8ce6-b095b522b6d3" />

-----

## 🛠️ Tecnologias Utilizadas

  * **Flutter e Dart:** Framework e linguagem principal para o desenvolvimento.
  * **Hive:** Banco de dados NoSQL local, leve e rápido, usado para todo o armazenamento de perfis e métricas.
  * **`fl_chart`:** Biblioteca para a criação dos gráficos de linha e de barra na tela de dashboard.
  * **`syncfusion_flutter_gauges`:** Biblioteca para a criação dos medidores (gauges) de risco.
  * **`flutter_local_notifications`:** Utilizada para agendar e disparar os lembretes de medição.

-----

## 🎓 Contexto Acadêmico

Este projeto foi desenvolvido para o **IV Simpósio de Disciplinas Extensionistas** do **Centro Universitário Estácio Ceará**, Campus Parangaba.

  * **Curso:** Ciências da Computação e Análise e Desenvolvimento de Sistemas.
  * **Disciplina:** ARA0089 – Programação para Dispositivos Móveis em Android.

-----

## 👨‍💻 Equipe e Orientador

### Equipe 7

  * Kauan Bezerra Monteiro 
  * João Gonçalves Neto
  * Caio Enzo de Menezes Vieira
  * Edson Fernando Araujo Silva

### Orientador

  * Juciarias Nascimento

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
