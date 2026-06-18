# BibleOS Build Scripts

This directory contains the automation logic used within the **Cubic** chroot environment to generate the BibleOS ISO image. The architecture follows **SOLID** principles, separating installation responsibilities into independent, maintainable modules.

## Modular Structure

- **`build-all.sh`**: The main orchestrator script. It is the only file you need to invoke. It manages execution order and sequentially runs the sub-modules.
- **`core/`**: System setup, repositories, dependencies, and base layers (Java, Wine, Codecs).
- **`apps/`**: Individual application logic (Holyrics, Mixing Station, OBS Studio).
- **`bible/`**: BibleTime setup and offline SWORD engine configuration.
- **`ui/`**: Visual identity, Dark Mode, icons, fonts, and user skeleton customization.

## How to Execute in Cubic

1. Open the Cubic chroot terminal.
2. Drag and drop the `scripts/` folder into the terminal window.
3. Make the orchestrator executable and run it:

```bash
chmod +x /scripts/build-all.sh
/scripts/build-all.sh
```

## **SOLID Principles Explained**

This project implements the **SOLID** design principles to ensure maintainability, scalability, and ease of debugging.

| Principle | Description | Implementation in BibleOS |
| :--- | :--- | :--- |
| **S**ingle Responsibility | Each module should have only one reason to change. | `core/`, `apps/`, `bible/`, and `ui/` are completely isolated. Changes to the OBS configuration do not affect Holyrics installation. |
| **O**pen/Closed | Open for extension, closed for modification. | We use **Positional Injection** for the main orchestrator (`build-all.sh`). To add a new feature (e.g., "Bible Translator"), you simply create a new file in `apps/` and add its name to the `MODULES` array in `build-all.sh`. No existing file needs to be edited. |
| **L**iskov Substitution | Subtypes must be substitutable for their base types. | N/A (Object-Oriented concept less directly applicable to bash scripts, but followed in spirit by maintaining consistent interfaces). |   
| **I**nterface Segregation | Clients should not be forced to depend on interfaces they do not use. | Each script is minimal. The `bible/` script only deals with SWORD; it doesn't know or care about OBS or NDI. |
| **D**ependency Inversion | Depend on abstractions, not concretions. | `build-all.sh` acts as an **Abstraction**. It depends on the "list of modules" (an abstraction), not on the specific logic inside `02-holyrics.sh`. This allows us to swap or reorder modules easily. |

## Common Commands

- **Run all modules**: `sudo ./build-all.sh`
- **Install apps only**: `sudo ./apps/build-all.sh`
- **Clean apt cache**: `sudo apt clean && rm -rf /tmp/*`