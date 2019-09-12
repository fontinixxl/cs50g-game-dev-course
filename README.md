# CS50's Introduction to Game Development
Repo where you can find all the assignment solutions of the CS50g course I have already completed.

For every lecture (game) we were given a distribution base code where we have to add a certain amount of new features in order to complete each of the assignment.

The lectures I have completed so far are the following:
1. Pong
    - Read and understand all of the Pong source code from Lecture 0.
    - Implement a basic AI for either Player 1 or 2 (or both!).
1. Flappy Bird
    - Read and understand all of the Flappy (Fifty!) Bird source code from Lecture 1.
    - Influence the generation of pipes so as to bring about more complicated level generation.
    - Give the player a medal for their performance, along with their score.
    - Implement a pause feature, just in case life gets in the way of jumping through pipes!
1. Breakout
     - Read and understand all of the Breakout source code from Lecture 1.
     - Add a powerup to the game that spawns two extra Balls.
     - Grow and shrink the Paddle when the player gains enough points or loses a life.
     - Add a locked Brick that will only open when the player collects a second new powerup, a key, which should only spawn when such a Brick exists and randomly as per the Ball powerup.
1. Match-3 
     - Implement time addition on matches, such that scoring a match extends the timer by 1 second per tile in a match.
     - Ensure Level 1 starts just with simple flat blocks (the first of each color in the sprite sheet), with later levels generating the       
       blocks with patterns on them (like the triangle, cross, etc.). These should be worth more points, at your discretion.
     - Creat random shiny versions of blocks that will destroy an entire row on match, granting points for each block in the row.
     - Only allow swapping when it results in a match. If there are no matches available to perform, reset the board.
     - (Optional) Implement matching using the mouse. (Hint: you’ll need push:toGame(x,y); see the push library’s documentation here for 
       details!
