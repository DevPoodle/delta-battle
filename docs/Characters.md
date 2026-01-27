# Characters

This is a description of the Character class, and should give you a decent idea of how to add your own characters.

# Creating a new character

To create a new character, you can simply create a new scene that inherits from the Character class. This scene must have a child Sprite2D node that contains the main sprite of your character. In the Character class exports, you have to set the "Main Sprite" property to this Sprite2D.

# Setting up the character

Almost all setup for the Character will happen in it's exported properties. Here, you should set quite a few things:
	1. Title: This is the character's name.
	2. Uses Magic: This decides whether the character uses magic or uses acts. (The magic system isn't well implemented yet, so there'll be a lot more manual work in setting it up)
	3. Main Color and Icon Color: The main color is the most common color associated with that character. The icon color is what color the character's icon will use. Typically, the icon color is a slightly darker and more saturated version of the main color.
	4. Icon: This is the icon that will appear next to the character's name in battle. It should be a 32x32 texture (although it doesn't have to be).
	5. Main Sprite: This is a reference to the main sprite of your character. The reason you have to set this, is so that the default character script can handle shaking the character during animations and changing their modulation.

# Setting up the chaqracter's stats

All characters have a field called "Base Fighter Stats". This will be where you set values like:
	1. Max HP (HP will be set automatically, you do not need to set it manually).
	2. Attack
	3. Defense
	4. Magic
	5. Money Multiplier
Set any of these values that you wish, any value that's not set will be 0, except Max HP which is 100.

# Creating a character script

If you want to properly implement custom animations for your character, you'll have to create a custom script for it. I'd recommend looking at the "Blue.gd" script for a good base. As you can see, you pretty much just have to implement the do_animation function for a fully-functioning character. It gives you a number saying what animation to play, and you have to return a signal that will emit when the animation is finished. The easiest way to do this is with an AnimationPlayer, as was done in Blue.gd.

# More control

Let's say you want more finely tuned control over a specific aspect of your character. I've tried to make that as easy as possible, by making a bunch of different functions for different things the character can do. So, you can just look through the base Character.gd, find the function that corresponds to what you want to change, and then override that in your custom character script. It should be fairly straightforward for the most part, although feel free to open up an issue on GitHub if you're can't figure out something.

# Customize Battle menu

Now that you've created a character, you probably want to test it out in game. By default, your character won't appear in the Customize Battle menu when you run the project. To add it, go to CustomizeBattle.tscn, and look in the node inspector. You should see exported arrays for all of the major things that can be customized. In the Characters array, create a new entry, and then drag n drop your character's scene into the array. It should now be choosable when you start the project.
