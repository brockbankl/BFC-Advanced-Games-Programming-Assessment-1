# Official MonoGame and 3D Platformer Resources

I will give you a quick tour of the project in class and then let you play with it. If you want to understand it properly, use the links on this page and spend some time following the code for yourself.

Everything linked here is maintained or published by the MonoGame project. I last checked the links on 2 August 2026.

## Start with the project

- [Official MonoGame 3D Platformer Starter Kit repository](https://github.com/MonoGame/Starter-Kit-3D-Platformer): source code, controls, project layout, Blender level workflow, and licence.
- [Official starter-kit reveal video](https://www.youtube.com/watch?v=_HTFDE4oDmY): a short look at the game and its main features.
- [MonoGame starter kits and demos](https://monogame.net/create/): MonoGame's current collection of starter projects and examples.
- [Original starter-kit announcement](https://monogame.net/blog/2025-07-16-3d-starter-kit/): some background on why the Foundation made the port. This is an older announcement, so use GitHub for the current project.

Use our course copy for practical and assessed work unless I tell you otherwise. It is a fixed snapshot, so an upstream update cannot suddenly break the project halfway through a lesson.

## Official development streams

The MonoGame team developed and explained the starter kit in several public streams. They are longer than the reveal video, but you get to see the team working with the real project rather than a cut-down example.

### Original reveal

- [MonoGame Open Hours, July 2025](https://www.youtube.com/watch?v=XYlfpiqM_fQ) (1 hour 8 minutes): the Open Hours session linked to the original starter-kit announcement.
- [3D Platformer Starter Kit reveal](https://www.youtube.com/watch?v=_HTFDE4oDmY): use this if you only want the short version first.

### MonoGame University: 3D Platformer Sample

Simon Jackson presented five sessions on the platformer. Watch them in this order if you want the full walkthrough:

1. [3D Platformer Sample, Session 1](https://www.youtube.com/watch?v=NJJ2YKBeF58) (1 hour 4 minutes)
2. [3D Platformer Sample, Session 2](https://www.youtube.com/watch?v=2eciHqXEv4A) (55 minutes)
3. [3D Platformer Sample, Session 3](https://www.youtube.com/watch?v=KE0SBS2D6ng) (1 hour 7 minutes)
4. [3D Platformer Sample, Session 4](https://www.youtube.com/watch?v=I1Uq46WAS9w) (1 hour 7 minutes)
5. [3D Platformer Sample, Session 5](https://www.youtube.com/watch?v=nK2jreobQfk) (1 hour 5 minutes)

You do not need to watch five hours of video before opening the code. Play the game and follow the class tour first. Come back to these when you want a fuller explanation.

### Later development and release

- [CodeTime with Tom Spilman: working on the 3D Platformer](https://www.youtube.com/watch?v=8S7OzNyI8TA) (2 hours 38 minutes): a long development session on the project itself.
- [MonoGame Open Hours, July 2026](https://www.youtube.com/watch?v=4v7wDXQJc8k) (1 hour 34 minutes): includes discussion of the public release.
- [Official MonoGame livestream archive](https://www.youtube.com/@MonoGame/streams): check here for anything recorded after this guide was updated.

The streams use whichever version of the project existed when they were recorded. Some folders or names may differ from our course copy. Check the code you actually have before copying anything.

## A first look through our course copy

Run the game first. Then follow one route through the code:

1. Open `WindowsDX/Program.cs`. On macOS or Linux, use `DesktopGL/Program.cs`. This starts the application.
2. Open `Source/PlatformerGame.cs` to find the main MonoGame class and game loop.
3. Look at `Source/Base/Scene.cs` and `Source/Base/SceneLoader.cs` to see how a level is loaded.
4. Compare `Source/Entities/Player.cs`, `Coin.cs`, and `Platform.cs` to see how the entities differ.
5. Look at `Source/Base/SceneRenderer.cs` and `PostProcessor.cs` for the rendering and screen effects.
6. Browse `Content/Assets/` and match the models, textures, sounds, levels, and effects to what you see in the game.
7. Open `Content/Builder/Builder.cs` and `Content/BuildContent.targets` to see how those files are processed during a build.

Do not try to read every class from top to bottom. Pick one question and trace the relevant code. You will get much more from it.

## MonoGame basics

- [What is MonoGame?](https://docs.monogame.net/articles/tutorials/building_2d_games/01_what_is_monogame/): what the framework provides and why it is cross-platform. It is part of the 2D course, but the main ideas also apply here.
- [MonoGame documentation home](https://docs.monogame.net/articles/): the main documentation and reference pages.
- [Getting started with MonoGame](https://docs.monogame.net/articles/getting_started/): supported operating systems, tools, and setup.
- [Official Visual Studio Code setup](https://docs.monogame.net/articles/getting_started/2_choosing_your_ide_vscode.html): C# support, MonoGame tools, templates, and the integrated terminal.
- [The `Game` and `Game1` lifecycle](https://docs.monogame.net/articles/tutorials/building_2d_games/03_the_game1_file/): explains `Initialize`, `LoadContent`, `Update`, and `Draw`. Our main class is called `PlatformerGame`, but it uses the same lifecycle.
- [Supported platforms](https://docs.monogame.net/articles/getting_started/platforms.html): desktop, mobile, and console targets.

## Content and assets

This starter kit uses the newer **Content Builder Project**. It does not use the older MGCB Editor workflow found in many tutorials.

- [Working with Content Builder Projects](https://docs.monogame.net/articles/getting_started/content_pipeline/content_builder_project.html): the most relevant content guide for this project. Pay particular attention to `ContentCollection`, include and exclude rules, importers, and processors.
- [Official Content Builder video](https://www.youtube.com/watch?v=QB43LgRmdNM): a short setup and workflow demonstration.
- [Content Pipeline chapter](https://docs.monogame.net/articles/tutorials/building_2d_games/05_content_pipeline/): explains why MonoGame processes assets before the game loads them. It uses the older MGCB route, so use it for the general idea and the Content Builder page for our actual setup.

Adding an asset involves four parts: put the source file in the correct folder, include it in the builder, process it successfully, and load it using the correct asset name. If an asset is missing, check those four parts in that order.

## 3D rendering

- [What is 3D rendering?](https://docs.monogame.net/articles/getting_to_know/whatis/graphics/WhatIs_3DRendering.html): world, view, and projection matrices, vertices, effects, textures, and the graphics device.
- [Official graphics how-to collection](https://docs.monogame.net/articles/getting_to_know/howto/graphics/): cameras, 3D rendering, render targets, graphics state, and collision examples.
- [Render a model with `BasicEffect`](https://docs.monogame.net/articles/getting_to_know/howto/graphics/HowTo_RenderModel.html): model loading, mesh drawing, lighting, and matrices.
- [Move and rotate a camera](https://docs.monogame.net/articles/getting_to_know/howto/graphics/HowTo_RotateMoveCamera.html): a small camera example to compare with the platformer.
- [Create a `BasicEffect`](https://docs.monogame.net/articles/getting_to_know/howto/graphics/HowTo_Create_a_BasicEffect.html): the state needed to draw basic 3D geometry.
- [Custom effects and shaders](https://docs.monogame.net/articles/getting_started/content_pipeline/custom_effects.html): effect files, shader compilation, and platform differences.
- [MonoGame API reference](https://docs.monogame.net/api/): use this when you need the exact members of a class or method.

The examples in the documentation are much smaller than this project. Find the simple version in the guide, then find the same idea in our code.

## More tutorials and help

- [MonoGame tutorial directory](https://docs.monogame.net/articles/tutorials/): official and recommended learning material.
- [Samples and demos](https://docs.monogame.net/articles/samples.html): other projects you can compare with this one.
- [Help and support](https://docs.monogame.net/articles/help_and_support.html): documentation, GitHub Discussions, and community support.

When I checked this list, MonoGame's dedicated beginner 3D tutorial was still marked as **coming soon**. Check the tutorial directory for updates. In the meantime, the starter kit, streams, and focused 3D pages above give you plenty to work with.

## Use the links to answer a question

Start with something specific:

- "Where does the game start?" Trace `Program.cs` into `PlatformerGame.cs`, then read the game-lifecycle chapter.
- "How does this model reach the screen?" Follow it from `Content/Assets/Models`, through the builder and `Content.Load`, then into the renderer.
- "Why does this shader need matrices?" Read the 3D rendering and `BasicEffect` pages, then compare them with an `.fx` file in `Content/Assets/Effects/`.
- "How is this cross-platform?" Compare `WindowsDX`, `DesktopGL`, and the shared `Source` project, then read the supported-platforms page.

You do not need to memorise the framework. Learn how to find the relevant code, check the official explanation, test a small change, and use the result as evidence.
