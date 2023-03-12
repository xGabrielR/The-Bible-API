## The Bible API

---

### Sessões do Projeto

- [1. Introdução](#1-introdução)
- [2. Estratégia de Solução](#2-estratégia-de-solução)
- [3. Desenvolvimento](#3-desenvolvimento)
- [4. Próximos Passos](#4-próximos-passos)
- [5. Referências](#5-referências)

---

### 1. Introdução
---

O projeto tem por principal fim coletar as informações importantes de todos os capítulos de todos os livros da biblia livre para todos disponíveis na API da biblia disponível neste link: [The Bible API](https://scripture.api.bible/).

A extração foi agendada diariamente para coletar os dados da API ao longo dos dias e armazenados localmente para futuras análises com o intuito de mantendo o histórico por dia das extrações em pastas separadas, assim consigo ter um controle de tudo que foi alterado em cada capítulo dos livros da Bíblia Livre para Todos por dia e não corro risco de possivelmente perder algum dado ou informação relevante que foi removida ou alterada no futuro. 

O projeto foi desenvolvido utilizando o próprio Powershell como ferramenta de requisição a diversos endpoints desta API.


### 2. Estratégia de Solução
---

Fazendo uma breve análise na documentação da API disponível nesse link: [API Documentation](https://scripture.api.bible/livedocs), a mesma possui alguns endpoints específicos que já auxiliam o desenvolvimento da solução.

Então desenvolvi um planejamento seguindo essa estrutura da *documentação da API* para ser desenvolvida com alguma ferramenta:

![Image Planejamento The Bible API](imgs/img_planing.png)

Esse é o planejamento e o fluxo de execução do script, para mais detalhes considere acessar o script: []().

Para efetivamente colocar em prática o planejamento, como ferramenta utilizei apenas o **Powershell** para o desenvolvimento do script responsável, e para o agendamento diário das execuções utilizei o **Agendador de Tarefas do Windows**.

1. O bloquinho em <font color="purple">roxo</font> representa o fluxo principal do script que é justamente as requisições a os endpoints da API.
2. O bloquinho em <font color="blue">azul</font> representa o armazenamento desses dados coletados.

Dessa forma, futuramente irei apenas melhorar cada bloquinho individualmente. 


### 3. Desenvolvimento
---

O desenvolvimento foi resumidamente transcrever o planejamento no script Powershell. Após a transcrição do planejamento, o código foi testado e modularizado em algumas funções específicas para auxiliar na manutenção futura.

Atualmente a API suporta até 5.000 requisições diárias no momento em que foi desenvolvido o Script, tendo esse conhecimento desenvolvido uma solução para minimizar a quantidade de requisições para evitar esse problema futuramente ou durante os agendamentos.

Abaixo estão alguns dos principais passos no desenvolvimento:

- [x] Verificação automática da Bíblia Livre para Todos (Biblia PT utilizada) caso ocorrer algum problema no ID utilizado.
- [x] Arquivos de Logs para monitoramento.
- [x] Armazenamento diário das requisições por `ano-mes-dia`.
- [x] Agendamento diário para futuras requisições.



### 4. Próximos Passos
---

Para os próximos passos seria mais o monitoramento e possíveis modularização do código, no momento estou satisfeito com a solução desenvolvida até agora e futuramente irei melhorar esses tópicos:

- [ ] Fazer o Parsing do HTML resultante do armazenamento dos conteúdos dos capítulos.
- [ ] Desenvolver outras modularização no script.
- [ ] Testar outras ferramentas para o Agendamento.
- [ ] Acompanhar as coletas para detectar eventuais problemas.


### 5. Referências
---

[1] [API.Bible](https://scripture.api.bible/): Home page da API da Biblia.

[2] [Docs API.Bible](https://docs.api.bible/): Documentações da API da Biblia.

