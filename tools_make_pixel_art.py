from PIL import Image, ImageDraw
from pathlib import Path
import random, math
out=Path('project/MurimRPG/assets/pixel')
S=(64,72)
# palette
ink='#131622'; hair='#191b28'; hairhi='#303445'; skin='#d5a080'; skinhi='#f0bd95'; robe='#26324b'; robehi='#3a4a6b'; inner='#172034'; gold='#d8b76e'; goldhi='#f2d992'; boot='#231f27'; teal='#75d3d0'; blade='#d3f6ec';

def hero(direction, action, frame):
    im=Image.new('RGBA',S,(0,0,0,0)); d=ImageDraw.Draw(im)
    # deterministic foot and body motion
    step=[0,2,0,-2][frame%4] if action=='walk' else [0,0,1,0][frame%4]
    lean=4 if action=='dodge' else (2 if action=='attack' and frame>=2 else 0)
    jump=[0,-3,-5,-2][frame%4] if action=='jump' else 0
    cx=32+lean
    # orientation down (front), up (rear), right profile
    side=direction=='right'; back=direction=='up'
    bob=[0,-1,0,1][frame%4] if action in ('idle','walk') else 0
    yoff=jump+bob
    # shadow
    d.ellipse((cx-15,56,cx+15,62),fill=(9,13,17,115))
    # afterimage dodge
    if action=='dodge' and frame in (1,2):
        d.ellipse((cx-22,24+yoff,cx+22,54+yoff),fill=(61,171,183,62))
    # feet stride shift
    lstep=step; rstep=-step
    if action=='attack': lstep=[-1,0,2,1][frame]; rstep=[1,0,-1,-1][frame]
    if action=='dodge': lstep=-3; rstep=4
    if action=='jump': lstep=-2; rstep=2
    # feet and lower legs
    for x,off in ((26+cx-32,lstep),(38+cx-32,rstep)):
        d.rectangle((x-3,49+yoff+off,x+2,56+yoff+off),fill=ink)
        d.rectangle((x-2,50+yoff+off,x+1,54+yoff+off),fill=boot)
        d.rectangle((x-4,54+yoff+off,x+4,57+yoff+off),fill=ink)
        d.rectangle((x-3,55+yoff+off,x+2,56+yoff+off),fill='#605347')
    # long hair rear hangs behind robe, visible from rear and sides
    if back or side:
        d.polygon([(cx-9,15+yoff),(cx+9,15+yoff),(cx+12,37+yoff),(cx+8,44+yoff),(cx+4,39+yoff),(cx,45+yoff),(cx-5,39+yoff),(cx-9,42+yoff)],fill=ink)
        d.polygon([(cx-7,17+yoff),(cx+7,17+yoff),(cx+8,34+yoff),(cx+4,39+yoff),(cx,34+yoff),(cx-5,40+yoff)],fill=hair)
        d.line((cx-4,20+yoff,cx-3,35+yoff),fill=hairhi,width=2)
        d.line((cx+3,19+yoff,cx+4,32+yoff),fill=hairhi,width=2)
    # robe silhouette shoulders, waist and flared hem
    if action=='dodge':
        body=[(cx-11,22+yoff),(cx+11,21+yoff),(cx+15,34+yoff),(cx+18,48+yoff),(cx+10,52+yoff),(cx-13,49+yoff),(cx-16,35+yoff)]
    else:
        sway=[0,1,0,-1][frame%4] if action=='walk' else 0
        body=[(cx-12,22+yoff),(cx+12,22+yoff),(cx+10+sway,35+yoff),(cx+17+sway,50+yoff),(cx+12,53+yoff),(cx-12,53+yoff),(cx-17+sway,50+yoff),(cx-10+sway,35+yoff)]
    d.polygon(body,fill=ink)
    d.polygon([(cx-10,23+yoff),(cx+10,23+yoff),(cx+8,35+yoff),(cx+14,49+yoff),(cx+10,51+yoff),(cx-10,51+yoff),(cx-14,49+yoff),(cx-8,35+yoff)],fill=robe)
    # robe front panels / broad folds
    d.polygon([(cx-2,25+yoff),(cx+3,25+yoff),(cx+6,48+yoff),(cx+1,51+yoff),(cx-3,46+yoff)],fill=robehi)
    d.polygon([(cx-8,36+yoff),(cx-3,37+yoff),(cx-5,49+yoff),(cx-10,50+yoff)],fill=inner)
    d.line((cx-13,48+yoff,cx-9,51+yoff,cx+9,51+yoff,cx+14,48+yoff),fill=gold,width=1)
    d.line((cx-5,35+yoff,cx,39+yoff,cx+5,35+yoff),fill=gold,width=1)
    # belt
    d.rectangle((cx-9,32+yoff,cx+9,35+yoff),fill=ink)
    d.rectangle((cx-8,33+yoff,cx+8,34+yoff),fill=gold)
    d.rectangle((cx-1,32+yoff,cx+2,35+yoff),fill=goldhi)
    # sleeves/arms, animation pose
    if action=='attack':
        armshift=[-3,1,8,5][frame]
    elif action=='dodge': armshift=7
    elif action=='walk': armshift=step*2
    else: armshift=0
    if side:
        # near arm and far sleeve in side profile
        d.polygon([(cx-7,23+yoff),(cx+7,24+yoff),(cx+14+armshift,33+yoff),(cx+9+armshift,37+yoff),(cx,31+yoff)],fill=ink)
        d.polygon([(cx-5,24+yoff),(cx+6,25+yoff),(cx+11+armshift,32+yoff),(cx+8+armshift,34+yoff),(cx,30+yoff)],fill=robehi)
        d.rectangle((cx+9+armshift,33+yoff,cx+12+armshift,38+yoff),fill=skin)
    else:
        for side_sign in (-1,1):
            sx=cx+side_sign*10
            sy=armshift if side_sign<0 else -armshift
            d.polygon([(sx-4,23+yoff),(sx+4,23+yoff),(sx+7,34+yoff+sy),(sx+3,37+yoff+sy),(sx-5,31+yoff)],fill=ink)
            d.polygon([(sx-3,24+yoff),(sx+3,24+yoff),(sx+5,33+yoff+sy),(sx+2,34+yoff+sy),(sx-4,30+yoff)],fill=robehi)
            d.rectangle((sx-2,34+yoff+sy,sx+2,38+yoff+sy),fill=skin)
            d.line((sx-4,32+yoff+sy,sx+4,32+yoff+sy),fill=gold,width=1)
    # collar and upper chest
    d.polygon([(cx-9,22+yoff),(cx-5,20+yoff),(cx,24+yoff),(cx+5,20+yoff),(cx+9,22+yoff),(cx+5,29+yoff),(cx,27+yoff),(cx-5,29+yoff)],fill=ink)
    d.polygon([(cx-7,22+yoff),(cx-4,21+yoff),(cx,25+yoff),(cx+4,21+yoff),(cx+7,22+yoff),(cx+4,27+yoff),(cx,26+yoff),(cx-4,27+yoff)],fill=gold)
    d.polygon([(cx-4,22+yoff),(cx,25+yoff),(cx+4,22+yoff),(cx+2,29+yoff),(cx-2,29+yoff)],fill=inner)
    # head skin and hair
    d.ellipse((cx-8,8+yoff,cx+8,25+yoff),fill=ink)
    d.ellipse((cx-6,10+yoff,cx+6,23+yoff),fill=skin)
    if back:
        d.ellipse((cx-7,8+yoff,cx+7,18+yoff),fill=hair)
        d.rectangle((cx-6,14+yoff,cx+6,20+yoff),fill=hair)
        d.rectangle((cx-1,10+yoff,cx+1,18+yoff),fill=hairhi)
        d.rectangle((cx-1,17+yoff,cx+1,20+yoff),fill=gold)
    elif side:
        d.pieslice((cx-8,7+yoff,cx+8,22+yoff),180,355,fill=hair)
        d.rectangle((cx-7,13+yoff,cx-1,21+yoff),fill=hair)
        d.rectangle((cx+4,14+yoff,cx+6,15+yoff),fill=ink)
        d.point((cx+4,14+yoff),fill=skinhi)
    else:
        d.pieslice((cx-8,7+yoff,cx+8,22+yoff),180,360,fill=hair)
        d.polygon([(cx-8,13+yoff),(cx-4,13+yoff),(cx-3,18+yoff),(cx,15+yoff),(cx+2,18+yoff),(cx+7,12+yoff),(cx+8,15+yoff),(cx+6,22+yoff),(cx-6,22+yoff)],fill=hair)
        # eyes, eyebrows
        d.point((cx-3,17+yoff),fill=ink); d.point((cx+3,17+yoff),fill=ink)
        d.line((cx-4,15+yoff,cx-2,15+yoff),fill=hair,width=1); d.line((cx+2,15+yoff,cx+4,15+yoff),fill=hair,width=1)
    # hair tie
    d.rectangle((cx-2,7+yoff,cx+2,9+yoff),fill=gold)
    d.rectangle((cx+2,6+yoff,cx+7,8+yoff),fill='#914b58')
    # sword/scabbard on back in idle/walk and a flash slash in attack
    if action in ('idle','walk') and (back or side):
        d.line((cx-15,26+yoff,cx+13,41+yoff),fill=ink,width=4)
        d.line((cx-14,26+yoff,cx+13,40+yoff),fill='#8c7760',width=2)
        d.line((cx-16,25+yoff,cx-11,28+yoff),fill=gold,width=2)
    if action=='attack':
        if frame in (1,2,3):
            # clean cyan crescent and bright edge
            if direction == 'down':
                box=(cx-19,18+yoff,cx+19,57+yoff); angles=(205,335)
                d.arc(box,angles[0],angles[1],fill=teal,width=3)
                d.arc((box[0]+3,box[1]+2,box[2]-3,box[3]-2),210,330,fill=blade,width=1)
                d.line((cx-14,43+yoff,cx+13,49+yoff),fill='#e7fff0',width=2)
            elif direction == 'up':
                box=(cx-19,-2+yoff,cx+19,38+yoff)
                d.arc(box,25,155,fill=teal,width=3)
                d.arc((box[0]+3,box[1]+2,box[2]-3,box[3]-2),30,150,fill=blade,width=1)
                d.line((cx-13,13+yoff,cx+13,6+yoff),fill='#e7fff0',width=2)
            else:
                box=(cx+3,12+yoff,cx+35,46+yoff)
                d.arc(box,205,325,fill=teal,width=3)
                d.arc((box[0]+3,box[1]+2,box[2]-2,box[3]-1),210,320,fill=blade,width=1)
                d.line((cx+7,38+yoff,cx+25,22+yoff),fill='#e7fff0',width=2)
    if action=='dodge' and frame in (1,2):
        d.line((cx-18,28+yoff,cx-7,28+yoff),fill='#6fc2c0',width=2)
        d.line((cx-21,34+yoff,cx-8,34+yoff),fill='#4e999f',width=2)
    return im

animations=['idle','walk','attack','dodge','jump']
dirs=['down','up','right','left']
frame_count=4
sheet=Image.new('RGBA',(len(animations)*frame_count*S[0],len(dirs)*S[1]),(0,0,0,0))
for row,direction in enumerate(dirs):
  for ai,action in enumerate(animations):
    for frame in range(frame_count):
      sheet.alpha_composite(hero(direction,action,frame),((ai*frame_count+frame)*S[0],row*S[1]))
sheet.save(out/'hero_sheet.png',optimize=True)
# 1024x1024 top-down forest-dojo floor, nearest-neighbor pixel texture.
rng=random.Random(44); W=H=1024
world=Image.new('RGB',(W,H),'#324b3f'); d=ImageDraw.Draw(world)
# grass patches in 16px cells
for y in range(0,H,16):
 for x in range(0,W,16):
  n=rng.randrange(0,8); color=['#30483d','#354e42','#2d453a','#395244','#324a3f','#3b5446','#2c4339','#364d40'][n]
  d.rectangle((x,y,x+15,y+15),fill=color)
  for _ in range(rng.randrange(1,5)):
   px=x+rng.randrange(2,15);py=y+rng.randrange(2,15)
   d.point((px,py),fill=rng.choice(['#45634d','#243d36','#597154']))
# central courtyard, stone tile blocks
stone=['#746f65','#827c70','#8c8476','#787568','#958979']
d.rectangle((252,180,772,844),fill='#272d2b')
d.rectangle((260,188,764,836),fill='#716c62')
for y in range(196,832,32):
 for x in range(268,756,32):
  col=rng.choice(stone)
  d.rectangle((x,y,x+29,y+29),fill=col)
  d.line((x+2,y+3,x+8,y+3),fill='#a69b87')
  for _ in range(3): d.point((x+rng.randrange(4,28),y+rng.randrange(4,28)),fill=rng.choice(['#625f59','#a89d8a']))
# stone entrance path
for y in list(range(0,190,28))+list(range(834,1024,28)):
 for x in range(432,592,28):
  c=rng.choice(['#696a61','#747267','#80796a'])
  d.rectangle((x,y,x+25,y+25),fill=c)
  d.line((x+3,y+4,x+9,y+4),fill='#988f7d')
# decorative circular training seal
cx=512;cy=514
d.ellipse((cx-110,cy-110,cx+110,cy+110),outline='#4e493f',width=5)
d.ellipse((cx-88,cy-88,cx+88,cy+88),outline='#c2a768',width=3)
d.ellipse((cx-68,cy-68,cx+68,cy+68),outline='#a88d55',width=2)
d.line((cx-70,cy,cx+70,cy),fill='#a88d55',width=2);d.line((cx,cy-70,cx,cy+70),fill='#a88d55',width=2)
d.polygon([(cx,cy-42),(cx+10,cy-10),(cx+42,cy),(cx+10,cy+10),(cx,cy+42),(cx-10,cy+10),(cx-42,cy),(cx-10,cy-10)],outline='#d2b26b')
world.save(out/'dojo_ground.png',optimize=True)
# tree atlas, 4 silhouettes, alpha pixel edges
atlas=Image.new('RGBA',(64*4,96),(0,0,0,0))
for i in range(4):
 t=Image.new('RGBA',(64,96),(0,0,0,0));q=ImageDraw.Draw(t)
 # canopy shadow
 q.ellipse((9,19,56,73),fill='#1a2d2b')
 q.polygon([(31,12),(11,37),(18,40),(5,57),(20,59),(12,72),(31,75),(51,73),(55,59),(62,55),(48,40),(55,35)],fill=['#315546','#355249','#49604d','#3d5747'][i])
 for bx,by,col in [(23,33,'#5c7451'),(39,29,'#647a50'),(15,49,'#455f48'),(35,48,'#526c4b'),(27,62,'#456047')]:
  q.rectangle((bx,by,bx+8,by+6),fill=col)
 q.rectangle((27,63,37,92),fill='#342b25');q.rectangle((30,67,34,92),fill='#624631')
 q.rectangle((19,73,28,77),fill='#4b3628');q.rectangle((35,80,45,84),fill='#4b3628')
 atlas.alpha_composite(t,(i*64,0))
atlas.save(out/'tree_atlas.png',optimize=True)
# Training post dummy sprite
D=Image.new('RGBA',(40,64),(0,0,0,0));q=ImageDraw.Draw(D)
q.ellipse((6,56,34,62),fill=(9,13,17,100));q.rectangle((15,14,25,58),fill='#34271e');q.rectangle((10,17,30,24),fill='#5b3c2b');q.rectangle((8,23,32,42),fill='#bb7651');q.rectangle((10,25,30,40),fill='#d58b5f');q.rectangle((5,20,35,26),fill='#473126');q.rectangle((17,8,23,20),fill='#46352a');q.rectangle((8,43,32,48),fill='#725039');q.rectangle((12,50,28,54),fill='#593d2a')
D.save(out/'training_dummy.png',optimize=True)
print('hero',sheet.size,(out/'hero_sheet.png').stat().st_size,'ground',(out/'dojo_ground.png').stat().st_size)
