# Soul Modes

There are 7 built-in soul modes that can be used.
By default they should work like they do in undertale or deltarune if they are present.

The types are as follows:
	1. Red.
	2. Blue: Has a function to easily change direction and intensity of gravity.
	3. Yellow: Has BIG SHOTS, but no extra visuals as of now. Also has a function to change directions.
	4. Purple: Works as it does in undertale.

# Adding a custom soul type

Adding a custom soul type is very simple.
Unlike characters, Soul Types are a resource, so to create a new one, create a SoulType Resource file and edit it to match what you want.

# Adding behavior to soul types

Each soul type accepts an array of scripts that it will use to determine the behavior of the soul.
You can simply drag and drop any valid script file into the array and it will work. All behaviors used in the base types can be found inside the "behaviors" folder which is inside the "soul" folder.

# Creating custom behavior

Any script that inherits from SoulBehavior is valid.
The SoulBehavior script has a number of functions, some of which are recommended to be used instead of what you'd normally use, for example, the "physics_tick" function instead of the built-in "_physics_process" function.
