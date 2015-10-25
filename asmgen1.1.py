#!/usr/bin/env python3


def cal(s,a,b):
    if('add' in s):
        return a+b
    elif('sub' in s):
        return a-b
    elif('and' in s):
        return a&b
    elif('xor' in s):
        return a^b
    elif('nor' in s):
        return ~(a|b)
    elif('or' in s):
        return a|b

exp = input()
f = open('out.s','a')

while(exp!='#'):
    (a,b,op) = exp.split(' ')
    ia = 0 
    ib = 0
    if 'x' in a:
        ia = int(a,16)
    else:
        ia = int(a)
    if 'x' in b:
        ib = int(b,16)
    else:
        ib = int(b)
    ic = cal(op,ia,ib)
    iah = ia>>16
    ial = ia&0xffff
    ibh = ib>>16
    ibl = ib&0xffff
    ich = ic>>16
    icl = ic&0xffff

    print('',file = f )
    if(ia>0xffff):
        print('lui  $t0 ,',hex(iah),file = f)
        print('li   $t1 ,',hex(ial),file = f)
        print('or   $t1 , $t1 , $t0',file = f)
    else:
        print('li   $t1 ,',hex(ial),file = f)

    if(ib>0xffff):
        print('lui  $t2 ,',hex(ibh),file = f)
        print('li   $t3 ,',hex(ibl),file = f)
        print('or   $t3 , $t3 , $t2',file = f)
    else:
        print('li   $t3 ,',hex(ibl),file = f)
    if (('i' in op) and (ib<0xffff)):
        print(op,   '$t4 ,',hex(ibl),file = f)
    else:
        print(op,   '$t4 , $t3 , $t1',file = f)

    if(ib>0xffff):
        print('lui  $s0 ,',hex(ich),file = f)
        print('li   $s1 ,',hex(icl),file = f)
        print('or   $s1 , $s1 , $s0',file = f)
    else:
        print('li   $s1 ,',hex(icl),file = f)
    print('bne  $s1 , $t4 , error',file = f)

    print(hex(cal(op,ia,ib)))
    exp = input()

f.close()
