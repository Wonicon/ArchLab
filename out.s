main:
lui  $t0 , 0x1
li   $t1 , 0x1
or   $t1 , $t1 , $t0
li   $t3 , 0x1
and $t4 , $t3 , $t1
li   $s1 , 0x0
bne  $s1 , $t4 , error

lui  $t0 , 0x1
li   $t1 , 0x0
or   $t1 , $t1 , $t0
li   $t3 , 0x1
add $t4 , $t3 , $t1
li   $s1 , 0x1
bne  $s1 , $t4 , error
lui $s3, 0x22
b good
error:
lui $s3, 0x11
good:
lui $s3, 0x22
