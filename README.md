# Sonic Battle Framework

![image](sbf_logo.png)

We’re making an open-source remake of Sonic Battle in Godot. Our goal is not only to recreate Sonic Battle with improved mechanics, but to create a framework for users to build on with their own custom content.

This project is both a **game** and a **framework**. The game can be downloaded as a standalone build to be played like normal. The source code will also be available for modders/fangame creators. 

The game will include mod support to allow players to add mods to their standalone build of the game without needing the source code. The Godot project will include editor tools to export characters/stages as standalone PCK archives that can be distributed to players to include in their build of the game. Users can also fork this project intirely

### Engine
This project is currently using Godot 4.6 Stable.

### Project Status
This project is currently in a very rough "proof-of-concept"/"prototype" state. It contains 4 playable characters and the basic Sonic Battle gameplay loop. Due to the project being built as a prototype, it is not suitable to be used as a framework at the moment. In the future, we'll be reworking the codebase to be cleaner and easier to work with. By forking this repo, you accept that you'll need to make your own changes to get it in a presentable state and that the codebase will be reworked heavily in the future.

#### Current Content List
- 4 Characters: Sonic, Tails, Knuckles, Shadow

- 7 Stages: Emerald Beach, Amy's Room, Battle Highway, Chao Ruins, Hologram (Broken), Holy Summit, Green Hill

- Each character only has a default ground and air skill. Guard skills are not implemented. 

- Skill select menu is not implemented

- Choosing your respawn location is not implemented

- Many effects are missing

- CPU players are not implemented.

- Online Multiplayer is not implemented, in the meantime you can use Parsec to play online

### Current Roadmap
The next build that will be released (0.1.2) will update all 4 characters to be more accurate to the original game and will include single screen multiplayer. The menus will also be improved for usability.

The following major release (0.2.x) will be a complete restructure/rework of the project to make it more suitable as a Framework and make it easier to add new characters, stages and other content. The gameplay code will also be reworked to support deterministic online netcode (but Online Multiplayer won't necessarily be added yet). 

### License
All source code is under the [MIT License](LICENSE). Assets such as sprites and audio are owned by SEGA.