return {
    [[
================================================
Current Version: v1.3.7

Download (Update) Successfully! Hello everyone! This is §cCyoltose§d.
The production of this game was greatly assisted by §p@Sake§d,
making the game content more complete and balanced. Thank you very much!
We also appreciate the friendly support from §p@Seaon§d and §p@Seako§d,
who significantly accelerated our development progress!

Thank you all for your support and attention along the way.
We will strive to make the game even better!
If you have any suggestions or opinions, please feel free to come to Discord for feedback!
================================================
News:
Added Scene 3 /scenep3!!!
Added /active!!!
Added 3 §y/player§d: [/playerSakuya], [/playerSanae], [/playerYoumu]
Added 15 §yChallenges§d: [/chall7], [/chall8], [/chall9], etc.
Added 40+ /items: /t174, /t201, etc.
Added §yPreset§d function for initial carry slots
Added §yPractice Mode§d for WX
Added numerous synergy effects
Added enemy armor mechanics to enhance bullet-dodging experience
Added §y"THE END"§d screen upon player death
Added flying text display with names and subtitles when picking up /items
Added §y[Settings]§d option to auto-hide title bar (Wins 11 only)
Added §gunlimited§d carry capacity for /item in Cheat Mode
Added /benefit: /t8
Added /trade: /t16
Added /infringe: /t34
Added /item tag: /tgdebuff, which will cause it not be selected in some random events

Removals:
Removed seasonal selection in /wxsys – §gseasons now Cycle Automatically
Removed §g"Luck Value"§d mechanism
Removed numerous meaningless §yAchievements
Removed §bConsecrate system
Removed §bCharacter Leveling system
Removed §b"Money"§d system, Monetization Mode replaced with Cheat Mode
Removed §bGame Manual
Removed lengthy death screens in Practice Mode

Adjustments:
Move the save location to the C drive directory
Standardized terminology usage
Adjusted some weather's effects
Adjusted quantity of /items's effects
Balanced difficulty for certain Waves
Smoothed chaos progression curve
Unlock most /items through §bExplore§d
Completing the game now accumulates /player progress to Unlock Talent
Standardized Game jargons:
Player's Bullet → Shots, Life → HP, etc.

Optimizations:
Improved UI rendering performance
Optimized logic for /item /t118
Reduced particle rendering impact from chaos increase on screen edges
Enhanced settings interface for §ysmoother mouse control
Added §yfree resolution scaling in display settings
Removed launcher interface, exe now §yDirectly Launches the game
Most lasers now count as bullets and are affected by weather (/w53, etc.)

Fixes:
Fixed /t107 activation failure
Fixed /t48 error
Fixed /t172 activation failure
Fixed synergy rendering issues between /t17 and player transparency
Fixed synergy conflict between /t17 and /t116
Fixed unfreezing player bug with /w74 and /w73 ice blocks
Fixed crash when /w79 encounters specific bullet patterns
Fixed /w75 mimicking /w33 causing gameplay issues
Fixed incorrect /w33 behavior in /challmode
Fixed /t85 error when /maxhp is "0"
Fixed negative /spellcR bug when /playerChiruno spams bombs
Corrected tags for /t44, /t117, /t37
Updated /t18's display name
Revised /t53's description
Adjusted /t6's effect implementation

Details:
/t153: /brR +77% → +177%
/t39: Grazing range is 28.6 → 36.9×/hitb (previously mistyped as 2.86×)
/t107: Grants 7 → 9f of /inv on use
/t142: Now deals hit damage every 12f
/t137: /expR +20% → +33%
/t158: Randomized values are now even more Chaotic
/t48: Grants /atk§g+0.25§d per /item with /tgsacrifice tag
/t49: Bullet transparency chance 5% → 7%
/t91: Triggers effect every 110 → 99 bullets fired
/t92: Snowflake deals 1 +25%/atk → 1 +50%/atk damage
/t99: Fireballs deal 45% → 58%/atk damage
/t154: /ss +1 → +2, /ssR +150% → +200%, /atkR -80% → -70%
/t117: +26 → +36f of /inv
/t168 etc: Taste improved! Each now deals 30% → 42%/atk damage
/t160: Bullets deal 0.7 → [Current Version Number] damage
/t172: Stack limit increased from 1 → 3, but requires stacking in one go
/t35: Redesigned due to removal of §gLuck Value§d mechanism
/t2: /spellme -7% → -11.1%
/t20: /atk +35% → +50% during /inv, max stacks 3 → 2
/t57: Slightly boosted values for levels (2) and (3)
/t60: Trigger chance 20% → 24%
/t79: Deals 35 → 50%/atk damage, cooldown 60 → 45f
/t118: Retains 1/2 → all /inv time, damage resumes after 99 → 120f
/t120: Base chance 7% → 7.7%, each /item grants +0.32% → *105% chance
/t159: Umbrella duration 75 → 90f, cooldown 105 → 90f
/t146: Angular speed doubled
/t144: Slightly increased trigger probability
/t55: /atk +0.5 → +1, HP drain slightly reduced
/t61: 5% → 10% chance to become /expp
/t73: Max grazing range 200% → 266%
/t76: Restores 25/hp → /maxhp +7
/t85: Generates /expp when losing 2.85% → 2.65%/hp
/t78: Bullet damage formula changed to 5a²*max(1, radius/100)%/atk, now fires bullet chains
/t52: Fake player bullets now fire symmetrically around screen center
/t45: Additional +9/br
/t94: /ssR +50% → +44%
/t116: /spd -0.45 → -0.35
/t135: Crimson aura deals 3% → 2%/atk damage
/t138: Item quality upgraded from Tier 1 → 2
/t116: /spd -0.35 → -0.25, new synergy with /t142
/t119: Reverses 2 → 3 bullet judgments
/t30: No longer drains all spellcard energy! Additional cost per trigger +10% → +5%/spelle
/t106: Revive grants 120 → 180f of /inv
/t108: Stars deal 20% → 49%/atk damage, disappear after 320 → 240f
/t123: Cooldown interval ≥75 → 65, 25% → 0.3 +33%/atk damage/f, banned from initial carry
/t128: Max HP increased from 20 → 30
/t129: Red main cannon: 3.3× damage → +20 flat damage
/t130: Green main cannon restores 0.025 → 0.064/hp on hit
/t101: Rainbow orbs deal 120% → 80%/atk damage
/t29: Laser damage -10%, duration -27f, repeat acquisition weight 10 → 7
/t63: Doll bullets deal 50% → 23%/atk damage
/t124: Scale bullets deal 60% → 45%/atk and 30 → 25%/atk damage respectively
/t126: Aura deals 5% → 3.3%/atk damage/f
/t100: Cancel points grant 0.01% → 0.02%/spelle
/t53: No longer exclusive to /bossRumia drops, now available on level-up
/t162: 6% → 2%/atk damage/f, duration increased
/t27: Grazing check every 2 → 8 bullets
/t90: "Sweet Venom" deals 0.19 → 0.12 bonus damage
/t115: "Lotus Shield" requires 60 → 90 canceled bullets to activate, max stored bullets 60 → 90
/t51: Barrier now moves vertically to block projectiles
/w3: Lightning damage 15 → 7

§ySpecial Thanks:§d
Sargolden
Nixxiam
ファルケン
]]
}