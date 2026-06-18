# Scripts de Construção do BibleOS

Esta pasta armazena a lógica de automação usada dentro do ambiente chroot do **Cubic** para gerar a imagem ISO do BibleOS. O código segue os princípios do **SOLID**, separando as responsabilidades de instalação por módulos independentes e de fácil manutenção.

## Organização Modular

- **`build-all.sh`**: Script orquestrador principal. É o único arquivo que você precisa invocar no terminal. Ele gerencia a ordem e executa sequencialmente os submódulos abaixo.
- **`core/`**: Setup inicial do sistema, repositórios, dependências e camadas base (Java, Wine, Codecs).
- **`apps/`**: Lógica de instalação de aplicativos (Holyrics, Mixing Station, OBS Studio).
- **`bible/`**: Configuração do BibleTime e motor offline SWORD.
- **`ui/`**: Gestão da identidade visual, Dark Mode, ícones, fontes e customização do `/etc/skel`.

## Como Executar no Cubic

1. Abra o terminal chroot do Cubic.
2. Arraste e solte a pasta `scripts/` para a janela do terminal.
3. Torne o orquestrador executável e rode-o:

```bash
chmod +x /scripts/build-all.sh
/scripts/build-all.sh
```

## Explicação dos Princípios S.O.L.I.D.

Este projeto implementa os princípios de design **SOLID** para garantir manutenibilidade, escalabilidade e facilidade de depuração.

| Princípio | Descrição | Implementação no BibleOS |
| :--- | :--- | :--- |
| **S**ingle Responsibility (Responsabilidade Única) | Cada módulo deve ter apenas uma razão para mudar. | `core/`, `apps/`, `bible/` e `ui/` são completamente isolados. Alterações na configuração do OBS não afetam a instalação do Holyrics. |
| **O**pen/Closed (Aberto/Fechado) | Aberto para extensão, fechado para modificação. | Usamos **Injeção Posicional** no orquestrador (`build-all.sh`). Para adicionar uma nova funcionalidade (ex: "Tradutor Bíblico"), você simplesmente cria um novo arquivo em `apps/` e adiciona o nome dele ao array `MODULES` em `build-all.sh`. Nenhum arquivo existente precisa ser editado. |
| **L**iskov Substitution (Substituição de Liskov) | Subtipos devem ser substituíveis por seus tipos base. | N/A (Conceito de Orientação a Objetos menos diretamente aplicável a scripts bash, mas seguido em espírito ao manter interfaces consistentes). |
| **I**nterface Segregation (Segregação de Interface) | Clientes não devem ser forçados a depender de interfaces que não usam. | Cada script é minimalista. O script `bible/` lida apenas com o SWORD; ele não sabe ou se importa com OBS ou NDI. |
| **D**ependency Inversion (Inversão de Dependência) | Depender de abstrações, não de concretudes. | `build-all.sh` atua como uma **Abstração**. Ele depende da "lista de módulos" (uma abstração), não da lógica específica dentro de `02-holyrics.sh`. Isso nos permite trocar ou reordenar módulos facilmente. |

## Comandos Comuns

- **Rodar todos os módulos**: `sudo ./build-all.sh`
- **Instalar apenas os apps**: `sudo ./apps/build-all.sh`
- **Limpar cache do apt**: `sudo apt clean && rm -rf /tmp/*`