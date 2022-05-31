# 🚗 PanqKart 🚗

A racing game with upgradable cars, fun races with up to 10 players, and so much more.\
Built by [Panquesito7 (David Leal)](https://github.com/Panquesito7), Pixel852, Crystal741, and other Minetest contributors.

**Please note that this is a work in progress game and is still in ALPHA stage.**\
**More awesome features are coming in the future. Stay tuned!**

## 🛠 Installation 🛠

- Unzip the archive, rename the folder to `panqkart` and
place it in `../minetest/games/`

- GNU/Linux: If you use a system-wide installation place
    it in `~/.minetest/games/`

## 🏰 Setting up the lobby/game 🏰

We've made a lobby for players to hang out, have fun, search for prizes, and so much more.\
You can, later on, join a race from a special part of the lobby if you want to play!

So now, let's get started to set up the lobby!\
In this section, we will setup our made lobby.

### The UI part, non-code

You need to download this repository. If you are experienced with Git, head to <https://docs.github.com/articles/cloning-a-repository>\
If you don't know anything about Git, click on the green `Code` button on this repository, then click on `Download ZIP`. For a more detailed guide, see <https://www.itpro.com/software/development/359246/how-to-download-from-github>.

After downloading, see the installation instructions above.\
You will need to install the [`WorldEdit`](https://github.com/Uberi/Minetest-WorldEdit) mod to add the lobby and the level.

Make a new world, with any name you want, with the mapgen set to `singlenode`, for the game `panqkart`. When joining, you will need to grant yourself all the privileges in order to fly and insert our pre-made lobby. Choose an area where you want to place the lobby by selecting position 1 and position 2. If you're unsure how to do this, check the [WorldEdit tutorial](https://github.com/Uberi/Minetest-WorldEdit/blob/master/Tutorial.md).

On the `panqkart` folder, you'll see a `schematics` folder. You will see a `lobby.we` file.\
Now, make a folder in your new world named `schems`, which can and will be accessed by WorldEdit.

Copy and paste the `lobby.we` file into the `schems` folder in your world directory.\
You're done pasting the lobby file into your world. Now, we must insert that file into our world.

If you already selected the area (we recommend placing position 1 and position 2 at the same position), you will need to go to your<br> inventory (by clicking on `i`), go to the `Creation` tab, then click on the [![inventory_plus_worldedit_gui](https://user-images.githubusercontent.com/51391473/171032521-cd536e49-e3f0-4784-95a1-5b6917a21fe4.png)](https://github.com/Uberi/Minetest-WorldEdit/blob/master/worldedit_gui/textures/inventory_plus_worldedit_gui.png)
 WorldEdit icon.

Now that you're on that page, click on `Save/Load`. It will ask you the name of the file you want to load. `lobby.we` is the name we will load. Once you click on `Load`, boom! The lobby will be there now. 🎉<br>
You will have to do some code changes in order to make the lobby successfully work properly. We will help you do it in the guide below.

### The code part

Let's get to configure some of the 

## 📷 Gallery 📷

Coming soon!

## 📜 Licensing 📜

Refer to `LICENSE.md` for more information.
