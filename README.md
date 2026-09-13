# Advanced Games Programming - Assessment 1

This repository is the standalone Assessment 1 MonoGame project. It is a pinned, tested copy of the MonoGame 3D Platformer starter kit for graphics, particles, HLSL shaders, AI, profiling and optimisation work.

## Start here

Use this route for normal college work.

1. Open PowerShell in this folder:

   ```text
   C:\Users\<your-login>\Documents\projects
   ```

2. Run this command to download the repository:

   ```powershell
   git clone https://github.com/brockbankl/BFC-Advanced-Games-Programming-Assessment-1.git
   ```

   If Git is not available, use GitHub's **Code > Download ZIP**, extract the repository inside `Documents\projects`, then open the extracted folder in Visual Studio Code.

3. Open the cloned `BFC-Advanced-Games-Programming-Assessment-1` folder in Visual Studio Code.
4. In File Explorer, double-click `Setup-Assessment1.cmd`.
5. Wait for the setup window to report `ASSESSMENT 1 SETUP COMPLETE`.
6. Open the repository in Visual Studio Code if it is not already open.
7. Run this command in the integrated terminal:

   ```powershell
   dotnet run --project ./WindowsDX/Platformer3D.csproj
   ```

You should now see the 3D platformer game window.

For normal college work, use `WindowsDX`. You can ignore the other platform projects unless your lecturer specifically asks you to use them. `DesktopGL` is primarily the macOS/Linux alternative.

If setup shows `[FAIL]`, stop and show your lecturer the complete error message and the PC number. Do not close the window first.

## What you need

- Visual Studio Code.
- Git, if you use the recommended clone route. Downloading a ZIP is a fallback.
- The .NET 10 SDK. The setup script can install a user-level copy on Windows when college policy allows.
- The recommended Visual Studio Code extensions:
  - C# Dev Kit by Microsoft (`ms-dotnettools.csdevkit`)
  - HLSL Tools by Tim Jones (`timgjones.hlsltools`)

The supplied setup is safe to run again. It checks tools, restores dependencies and builds the selected desktop project. It does not require a separate Windows Terminal, Command Prompt or administrator account when the college PC permits user-level installation.

## If you downloaded a ZIP

Extract the complete folder into `C:\Users\<your-login>\Documents\projects`, then open the extracted `BFC-Advanced-Games-Programming-Assessment-1` folder in Visual Studio Code. Do not open only `Source`, `Content` or an individual `.cs` file.

The repository root is the folder containing `README.md`, `Platformer3D.slnx`, `Source`, `Content`, `WindowsDX` and `DesktopGL`. There is no additional Assessment 1 folder to enter.

## Run and debug

The normal Windows command is:

```powershell
dotnet run --project ./WindowsDX/Platformer3D.csproj
```

On macOS or Linux, use:

```bash
dotnet run --project ./DesktopGL/Platformer3D.csproj
```

You can also use **Terminal > Run Task** in Visual Studio Code:

- **BFC: Setup Assessment 1** runs the setup script.
- **BFC: Build WindowsDX** builds the normal college target.
- **BFC: Run WindowsDX** builds and runs the normal college target.
- **BFC: Build DesktopGL** and **BFC: Run DesktopGL** are for macOS/Linux.

The **Run and Debug** view contains `WindowsDX` and `DesktopGL` launch configurations. Select the configuration appropriate to your computer and press `F5`. If the debug route is unavailable, use the integrated-terminal command above; it runs the same project.

## Repository layout

- `Source/` contains the C# game loop, scenes, entities, rendering, collision and gameplay code.
- `Content/` contains source assets and the MonoGame Content Builder project.
- `WindowsDX/` is the normal Windows desktop project.
- `DesktopGL/` is the macOS/Linux desktop project.
- `DesktopVK/`, `WindowsDX12/`, `Android/` and `iOS/` are inherited upstream platform targets. Ignore them unless your lecturer asks you to use one.
- `docs/OFFICIAL_MONOGAME_RESOURCES.md` links to official MonoGame resources and the 3D platformer references.
- `upstream.json` records the exact starter-kit revision used for this teaching baseline.

## First check before changing code

Run the game once before making changes. Confirm that the supplied starting version works, then make one small change at a time. Follow the version-control and submission instructions given in class.

When you have changed code or content, run the same WindowsDX command again. Keep the terminal open while the game runs; press `Ctrl+C` in that terminal if needed to stop it.

## Troubleshooting

### The setup script will not run

Use the included `Setup-Assessment1.cmd` by double-clicking it. If you run the script in the integrated terminal instead, use:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Setup-Assessment1.ps1
```

This policy override applies only to that PowerShell process; it does not change Windows security settings.

### The wrong folder is open

Check the VS Code Explorer. You should see `Platformer3D.slnx`, `Source`, `Content`, `WindowsDX` and `DesktopGL` at the top level. If you only see one of those folders, use **File > Open Folder** and select the complete repository folder.

### .NET or NuGet restore fails

Run setup again and read the first `[FAIL]` or restore error. The setup checks for the .NET 10 SDK and the official NuGet.org source. If the college network blocks installation or package restore, keep the complete error visible and show it to your lecturer or college IT.

### The game does not launch on Windows

Confirm that you used:

```powershell
dotnet run --project ./WindowsDX/Platformer3D.csproj
```

Close any already-running copy of the game and try again. Do not run the `DesktopGL` project on a normal college Windows PC unless your lecturer asks you to.

### The project is in the wrong location

On college PCs, move or reclone the complete repository below:

```text
C:\Users\<your-login>\Documents\projects\BFC-Advanced-Games-Programming-Assessment-1
```

Then reopen that folder in Visual Studio Code and repeat setup.

## Licensing and provenance

This course project preserves the original MonoGame and Kenney licence and attribution information in [`LICENSE.md`](LICENSE.md) and the asset folders. The original starter kit is [MonoGame/Starter-Kit-3D-Platformer](https://github.com/MonoGame/Starter-Kit-3D-Platformer). The pinned source commit and licence details are recorded in [`upstream.json`](upstream.json) and [`ORIGIN.md`](ORIGIN.md).
