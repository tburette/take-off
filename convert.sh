#/bin/bash
#8
#16
#21
#25
#27-32
#34-39
#41
#43-44
#46
#48-52
#54-56
#58
#61-64
#gifsicle   --optimize=3  --colors 256 --crop 0,0+-1x174 \
#gifsicle   --optimize=3  --colors 256 --crop 0,175+-1x42 \
gifsicle   --optimize=3  --colors 256 --crop 0,218+-1x-65 \
-d15 \
`jot -w "#"  - 0 7  1` \
`jot -w "#"  - 9 15  1` \
`jot -w "#"  - 17 20  1` \
`jot -w "#"  - 22 24  1` \
'#26' \
-d90 \
'#33' \
-d90 \
'#40' \
-d30 \
'#42' \
-d45 \
'#45' \
-d30 \
'#47' \
-d75 \
'#53' \
-d30 \
'#57' \
-d15 \
'#59' \
-d120 \
'#60' \
\
<video.gif  > result.gif
