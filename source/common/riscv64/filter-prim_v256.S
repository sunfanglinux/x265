/*****************************************************************************
 * Copyright (C) 2025 MulticoreWare, Inc
 *
 * Authors: Sun Fang <fangsun@linux.alibaba.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02111, USA.
 *
 * This program is also available under a commercial proprietary license.
 * For more information, contact us at license @ x265.com.
 *****************************************************************************/

#include "asm.S"

.align 4
.text

#if !HIGH_BIT_DEPTH

.macro PUSH_STACK
    addi           sp, sp, -128
    sd             s2, 0(sp)
    sd             s3, 8(sp)
    sd             s4, 16(sp)
    sd             ra, 24(sp)
.endm

.macro POP_STACK
    ld             s2, 0(sp)
    ld             s3, 8(sp)
    ld             s4, 16(sp)
    ld             ra, 24(sp)
    addi           sp, sp, 128
.endm

.macro COEFFIDX_1_3_INIT
    li             t0, 4
    li             t1, -10
    li             t2, 58
    li             t3, 17
    li             t4, -5
.endm

.macro COEFFIDX_1_2_3_INIT
    li             t0, 4
    li             t1, -10
    li             t2, 58
    li             t3, 17
    li             t4, -5
    li             t5, -11
    li             t6, 40
.endm

.macro HV_PP_N8_COEFFIDX1_H_COEFFIDX1_2_V_INIT
    li             s2, 1
    slli           s3, s2, 13   #offset
    slli           s2, s2, 7    #base
    slli           s4, a1, 1
    addi           a0, a0, -3
    sub            a0, a0, a1
    sub            a0, a0, s4
    addi           a1, a1, -6
.endm

.macro HV_PP_N8_COEFFIDX2_H_COEFFIDX1_2_V_INIT
    li             s2, 1
    slli           s3, s2, 13   #offset
    slli           s2, s2, 7    #base
    slli           s4, a1, 1
    addi           a0, a0, -3
    sub            a0, a0, a1
    sub            a0, a0, s4
    addi           a1, a1, -7
.endm

.macro HV_PP_N8_COEFFIDX3_H_COEFFIDX1_2_V_INIT
    li             s2, 1
    slli           s3, s2, 13   #offset
    slli           s2, s2, 7    #base
    slli           s4, a1, 1
    addi           a0, a0, -2
    sub            a0, a0, a1
    sub            a0, a0, s4
    addi           a1, a1, -6
.endm

.macro HV_PP_N8_COEFFIDX1_H_COEFFIDX3_V_INIT
    li             s2, 1
    slli           s3, s2, 13   #offset
    slli           s2, s2, 7    #base
    slli           s4, a1, 1
    addi           a0, a0, -3
    sub            a0, a0, s4
    addi           a1, a1, -6
.endm

.macro HV_PP_N8_COEFFIDX2_H_COEFFIDX3_V_INIT
    li             s2, 1
    slli           s3, s2, 13   #offset
    slli           s2, s2, 7    #base
    slli           s4, a1, 1
    addi           a0, a0, -3
    sub            a0, a0, s4
    addi           a1, a1, -7
.endm

.macro HV_PP_N8_COEFFIDX3_H_COEFFIDX3_V_INIT
    li             s2, 1
    slli           s3, s2, 13   #offset
    slli           s2, s2, 7    #base
    slli           s4, a1, 1
    addi           a0, a0, -2
    sub            a0, a0, s4
    addi           a1, a1, -6
.endm

.macro LOAD_HORIZ_7 vdst0, vdst1, vdst2, vdst3, vdst4, vdst5, vdst6, stride, src
    vle8.v         \vdst0, (\src)
    addi           \src, \src, 1
    vle8.v         \vdst1, (\src)
    addi           \src, \src, 1
    vle8.v         \vdst2, (\src)
    addi           \src, \src, 1
    vle8.v         \vdst3, (\src)
    addi           \src, \src, 1
    vle8.v         \vdst4, (\src)
    addi           \src, \src, 1
    vle8.v         \vdst5, (\src)
    addi           \src, \src, 1
    vle8.v         \vdst6, (\src)
    add            \src, \src, \stride
.endm

.macro LOAD_HORIZ_8 vdst0, vdst1, vdst2, vdst3, vdst4, vdst5, vdst6, vdst7, stride, src
    vle8.v         \vdst0, (\src)
    addi           \src, \src, 1
    vle8.v         \vdst1, (\src)
    addi           \src, \src, 1
    vle8.v         \vdst2, (\src)
    addi           \src, \src, 1
    vle8.v         \vdst3, (\src)
    addi           \src, \src, 1
    vle8.v         \vdst4, (\src)
    addi           \src, \src, 1
    vle8.v         \vdst5, (\src)
    addi           \src, \src, 1
    vle8.v         \vdst6, (\src)
    addi           \src, \src, 1
    vle8.v         \vdst7, (\src)
    add            \src, \src, \stride
.endm

.macro HV_PP_N8_H_LOAD_HORIZ_7 stride, src
    LOAD_HORIZ_7   v0, v1, v2, v3, v4, v5, v6, \stride, \src
.endm

.macro HV_PP_N8_H_LOAD_HORIZ_8 stride, src
    LOAD_HORIZ_8   v0, v1, v2, v3, v4, v5, v6, v7, \stride, \src
.endm

.macro HV_PP_N8_COEFFIDX1_H vdst, vtemp, e8lmul, e16lmul, size, stride, src, offset
    vsetivli       zero, \size, e8, \e8lmul, ta, ma
    HV_PP_N8_H_LOAD_HORIZ_7 \stride, \src
    vwmulu.vx      \vdst, v1, t0
    vwmaccsu.vx    \vdst, t1, v2
    vwmaccu.vx     \vdst, t2, v3
    vwmaccu.vx     \vdst, t3, v4
    vwmaccsu.vx    \vdst, t4, v5
    vwsubu.vv      \vtemp, v6, v0
    vsetivli       zero, \size, e16, \e16lmul, ta, ma
    vadd.vv        \vdst, \vdst, \vtemp
    vsub.vx        \vdst, \vdst, \offset
.endm

.macro HV_PP_N8_COEFFIDX2_H vdst, e8lmul, e16lmul, size, stride, src, offset
    vsetivli       zero, \size, e8, \e8lmul, ta, ma
    HV_PP_N8_H_LOAD_HORIZ_8 \stride, \src
    vwaddu.vv      v8, v3, v4
    vwaddu.vv      v9, v2, v5
    vwaddu.vv      v10, v1, v6
    vwaddu.vv      v11, v0, v7
    vsetivli       zero, \size, e16, \e16lmul, ta, ma
    vmul.vx        \vdst, v8, t6
    vmacc.vx       \vdst, t5, v9
    vmacc.vx       \vdst, t0, v10
    vsub.vv        \vdst, \vdst, v11
    vsub.vx        \vdst, \vdst, \offset
.endm

.macro HV_PP_N8_COEFFIDX3_H vdst, vtemp, e8lmul, e16lmul, size, stride, src, offset
    vsetivli       zero, \size, e8, \e8lmul, ta, ma
    HV_PP_N8_H_LOAD_HORIZ_7 \stride, \src
    vwmulu.vx      \vdst, v2, t3
    vwmaccsu.vx    \vdst, t4, v1
    vwmaccu.vx     \vdst, t2, v3
    vwmaccsu.vx    \vdst, t1, v4
    vwmaccu.vx     \vdst, t0, v5
    vwsubu.vv      \vtemp, v0, v6
    vsetivli       zero, \size, e16, \e16lmul, ta, ma
    vadd.vv        \vdst, \vdst, \vtemp
    vsub.vx        \vdst, \vdst, \offset
.endm

.macro HV_PP_N8_COEFFIDX1_V vdst0, vdst1, vsrc0, vsrc1, vsrc2, vsrc3, vsrc4, vsrc5, vsrc6, vsrc7, vtemp0, vtemp1, e8lmul, e16lmul, size, stride, dst, base
    vsetivli       zero, \size, e16, \e16lmul, ta, ma
    vwsub.vv       \vdst0, \vsrc6, \vsrc0
    vwsub.vv       \vdst1, \vsrc7, \vsrc1
    vwmacc.vx      \vdst0, t0, \vsrc1
    vwmacc.vx      \vdst1, t0, \vsrc2
    vwmacc.vx      \vdst0, t1, \vsrc2
    vwmacc.vx      \vdst1, t1, \vsrc3
    vwmacc.vx      \vdst0, t2, \vsrc3
    vwmacc.vx      \vdst1, t2, \vsrc4
    vwmacc.vx      \vdst0, t3, \vsrc4
    vwmacc.vx      \vdst1, t3, \vsrc5
    vwmacc.vx      \vdst0, t4, \vsrc5
    vwmacc.vx      \vdst1, t4, \vsrc6
    vnclip.wi      \vtemp0, \vdst0, 12
    vnclip.wi      \vtemp1, \vdst1, 12
    vadd.vx        \vtemp0, \vtemp0, \base
    vadd.vx        \vtemp1, \vtemp1, \base
    vmax.vx        \vtemp0, \vtemp0, x0
    vmax.vx        \vtemp1, \vtemp1, x0
    vsetivli       zero, \size, e8, \e8lmul, ta, ma
    vnclipu.wi     \vdst0, \vtemp0, 0
    vnclipu.wi     \vdst1, \vtemp1, 0
    vse8.v         \vdst0, (\dst)
    add            \dst, \dst, \stride
    vse8.v         \vdst1, (\dst)
    add            \dst, \dst, \stride
.endm

.macro HV_PP_N8_COEFFIDX2_V vdst0, vdst1, vsrc0, vsrc1, vsrc2, vsrc3, vsrc4, vsrc5, vsrc6, vsrc7, vsrc8, vtemp0, vtemp1, e8lmul, e16lmul, e32lmul, size, stride, dst, base
    vsetivli       zero, \size, e16, \e16lmul, ta, ma
    vwadd.vv       v0, \vsrc3, \vsrc4
    vwadd.vv       v2, \vsrc2, \vsrc5
    vwadd.vv       v4, \vsrc1, \vsrc6
    vwadd.vv       v6, \vsrc0, \vsrc7
    vsetivli       zero, \size, e32, \e32lmul, ta, ma
    vmul.vx        \vdst0, v0, t6
    vmacc.vx       \vdst0, t5, v2
    vmacc.vx       \vdst0, t0, v4
    vsub.vv        \vdst0, \vdst0, v6
    vsetivli       zero, \size, e16, \e16lmul, ta, ma
    vwadd.vv       v0, \vsrc4, \vsrc5
    vwadd.vv       v2, \vsrc3, \vsrc6
    vwadd.vv       v4, \vsrc2, \vsrc7
    vwadd.vv       v6, \vsrc1, \vsrc8
    vsetivli       zero, \size, e32, \e32lmul, ta, ma
    vmul.vx        \vdst1, v0, t6
    vmacc.vx       \vdst1, t5, v2
    vmacc.vx       \vdst1, t0, v4
    vsub.vv        \vdst1, \vdst1, v6
    vsetivli       zero, \size, e16, \e16lmul, ta, ma
    vnclip.wi      \vtemp0, \vdst0, 12
    vnclip.wi      \vtemp1, \vdst1, 12
    vadd.vx        \vtemp0, \vtemp0, \base
    vadd.vx        \vtemp1, \vtemp1, \base
    vmax.vx        \vtemp0, \vtemp0, x0
    vmax.vx        \vtemp1, \vtemp1, x0
    vsetivli       zero, \size, e8, \e8lmul, ta, ma
    vnclipu.wi     \vdst0, \vtemp0, 0
    vnclipu.wi     \vdst1, \vtemp1, 0
    vse8.v         \vdst0, (\dst)
    add            \dst, \dst, \stride
    vse8.v         \vdst1, (\dst)
    add            \dst, \dst, \stride
.endm

.macro HV_PP_N8_COEFFIDX3_V vdst0, vdst1, vsrc0, vsrc1, vsrc2, vsrc3, vsrc4, vsrc5, vsrc6, vsrc7, vtemp0, vtemp1, e8lmul, e16lmul, size, stride, dst, base
    vsetivli       zero, \size, e16, \e16lmul, ta, ma
    vwsub.vv       \vdst0, \vsrc0, \vsrc6
    vwsub.vv       \vdst1, \vsrc1, \vsrc7
    vwmacc.vx      \vdst0, t4, \vsrc1
    vwmacc.vx      \vdst1, t4, \vsrc2
    vwmacc.vx      \vdst0, t3, \vsrc2
    vwmacc.vx      \vdst1, t3, \vsrc3
    vwmacc.vx      \vdst0, t2, \vsrc3
    vwmacc.vx      \vdst1, t2, \vsrc4
    vwmacc.vx      \vdst0, t1, \vsrc4
    vwmacc.vx      \vdst1, t1, \vsrc5
    vwmacc.vx      \vdst0, t0, \vsrc5
    vwmacc.vx      \vdst1, t0, \vsrc6
    vnclip.wi      \vtemp0, \vdst0, 12
    vnclip.wi      \vtemp1, \vdst1, 12
    vadd.vx        \vtemp0, \vtemp0, \base
    vadd.vx        \vtemp1, \vtemp1, \base
    vmax.vx        \vtemp0, \vtemp0, x0
    vmax.vx        \vtemp1, \vtemp1, x0
    vsetivli       zero, \size, e8, \e8lmul, ta, ma
    vnclipu.wi     \vdst0, \vtemp0, 0
    vnclipu.wi     \vdst1, \vtemp1, 0
    vse8.v         \vdst0, (\dst)
    add            \dst, \dst, \stride
    vse8.v         \vdst1, (\dst)
    add            \dst, \dst, \stride
.endm

.macro HV_PP_8_X_4 w e8lmul e16lmul e32lmul
function x265_8_interp_hv_pp_8_\w\()_4_1_1_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_3_INIT
    HV_PP_N8_COEFFIDX1_H_COEFFIDX1_2_V_INIT
    HV_PP_N8_COEFFIDX1_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v14, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v15, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v16, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v17, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_V v24, v26, v8, v9, v10, v11, v12, v13, v14, v15, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_V v24, v26, v10, v11, v12, v13, v14, v15, v16, v17, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_4_1_2_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_2_3_INIT
    HV_PP_N8_COEFFIDX1_H_COEFFIDX1_2_V_INIT
    HV_PP_N8_COEFFIDX1_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v14, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v15, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v16, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v17, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v18, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_V v24, v26, v8, v9, v10, v11, v12, v13, v14, v15, v16, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_V v24, v26, v10, v11, v12, v13, v14, v15, v16, v17, v18, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_4_1_3_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_3_INIT
    HV_PP_N8_COEFFIDX1_H_COEFFIDX3_V_INIT
    HV_PP_N8_COEFFIDX1_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v14, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v15, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v16, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v17, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_V v24, v26, v8, v9, v10, v11, v12, v13, v14, v15, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_V v24, v26, v10, v11, v12, v13, v14, v15, v16, v17, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_4_2_1_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_2_3_INIT
    HV_PP_N8_COEFFIDX2_H_COEFFIDX1_2_V_INIT
    HV_PP_N8_COEFFIDX2_H v12, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v13, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v14, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v15, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v16, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v17, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v18, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v19, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v20, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v21, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_V v24, v26, v12, v13, v14, v15, v16, v17, v18, v19, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_V v24, v26, v14, v15, v16, v17, v18, v19, v20, v21, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_4_2_2_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_2_3_INIT
    HV_PP_N8_COEFFIDX2_H_COEFFIDX1_2_V_INIT
    HV_PP_N8_COEFFIDX2_H v12, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v13, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v14, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v15, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v16, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v17, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v18, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v19, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v20, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v21, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v22, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_V v24, v26, v12, v13, v14, v15, v16, v17, v18, v19, v20, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_V v24, v26, v14, v15, v16, v17, v18, v19, v20, v21, v22, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_4_2_3_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_2_3_INIT
    HV_PP_N8_COEFFIDX2_H_COEFFIDX3_V_INIT
    HV_PP_N8_COEFFIDX2_H v12, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v13, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v14, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v15, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v16, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v17, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v18, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v19, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v20, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v21, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_V v24, v26, v12, v13, v14, v15, v16, v17, v18, v19, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_V v24, v26, v14, v15, v16, v17, v18, v19, v20, v21, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_4_3_1_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_3_INIT
    HV_PP_N8_COEFFIDX3_H_COEFFIDX1_2_V_INIT
    HV_PP_N8_COEFFIDX3_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v14, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v15, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v16, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v17, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_V v24, v26, v8, v9, v10, v11, v12, v13, v14, v15, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_V v24, v26, v10, v11, v12, v13, v14, v15, v16, v17, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_4_3_2_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_2_3_INIT
    HV_PP_N8_COEFFIDX3_H_COEFFIDX1_2_V_INIT
    HV_PP_N8_COEFFIDX3_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v14, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v15, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v16, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v17, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v18, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_V v24, v26, v8, v9, v10, v11, v12, v13, v14, v15, v16, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_V v24, v26, v10, v11, v12, v13, v14, v15, v16, v17, v18, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_4_3_3_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_3_INIT
    HV_PP_N8_COEFFIDX3_H_COEFFIDX3_V_INIT
    HV_PP_N8_COEFFIDX3_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v14, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v15, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v16, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v17, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_V v24, v26, v8, v9, v10, v11, v12, v13, v14, v15, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_V v24, v26, v10, v11, v12, v13, v14, v15, v16, v17, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc
.endm

HV_PP_8_X_4 4 mf4 mf2 m1
HV_PP_8_X_4 8 mf4 mf2 m1
HV_PP_8_X_4 16 mf2 m1 m2

.macro HV_PP_8_X_8 w e8lmul e16lmul e32lmul
function x265_8_interp_hv_pp_8_\w\()_8_1_1_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_3_INIT
    HV_PP_N8_COEFFIDX1_H_COEFFIDX1_2_V_INIT
    HV_PP_N8_COEFFIDX1_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v14, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v15, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v16, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v17, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_V v24, v26, v8, v9, v10, v11, v12, v13, v14, v15, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_V v24, v26, v10, v11, v12, v13, v14, v15, v16, v17, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_H v18, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v19, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v20, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v21, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_V v24, v26, v12, v13, v14, v15, v16, v17, v18, v19, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_V v24, v26, v14, v15, v16, v17, v18, v19, v20, v21, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_8_1_2_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_2_3_INIT
    HV_PP_N8_COEFFIDX1_H_COEFFIDX1_2_V_INIT
    HV_PP_N8_COEFFIDX1_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v14, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v15, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v16, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v17, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v18, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_V v24, v26, v8, v9, v10, v11, v12, v13, v14, v15, v16, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_V v24, v26, v10, v11, v12, v13, v14, v15, v16, v17, v18, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_H v19, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v20, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v21, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v22, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_V v24, v26, v12, v13, v14, v15, v16, v17, v18, v19, v20, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_V v24, v26, v14, v15, v16, v17, v18, v19, v20, v21, v22, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_8_1_3_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_3_INIT
    HV_PP_N8_COEFFIDX1_H_COEFFIDX3_V_INIT
    HV_PP_N8_COEFFIDX1_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v14, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v15, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v16, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v17, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_V v24, v26, v8, v9, v10, v11, v12, v13, v14, v15, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_V v24, v26, v10, v11, v12, v13, v14, v15, v16, v17, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_H v18, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v19, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v20, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v21, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_V v24, v26, v12, v13, v14, v15, v16, v17, v18, v19, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_V v24, v26, v14, v15, v16, v17, v18, v19, v20, v21, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_8_2_1_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_2_3_INIT
    HV_PP_N8_COEFFIDX2_H_COEFFIDX1_2_V_INIT
    HV_PP_N8_COEFFIDX2_H v12, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v13, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v14, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v15, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v16, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v17, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v18, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v19, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v20, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v21, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_V v24, v26, v12, v13, v14, v15, v16, v17, v18, v19, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_V v24, v26, v14, v15, v16, v17, v18, v19, v20, v21, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_H v22, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v23, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v24, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v25, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_V v26, v28, v16, v17, v18, v19, v20, v21, v22, v23, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_V v26, v28, v18, v19, v20, v21, v22, v23, v24, v25, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_8_2_2_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_2_3_INIT
    HV_PP_N8_COEFFIDX2_H_COEFFIDX1_2_V_INIT
    HV_PP_N8_COEFFIDX2_H v12, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v13, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v14, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v15, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v16, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v17, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v18, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v19, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v20, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v21, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v22, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_V v24, v26, v12, v13, v14, v15, v16, v17, v18, v19, v20, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_V v24, v26, v14, v15, v16, v17, v18, v19, v20, v21, v22, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_H v23, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v24, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v25, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v26, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_V v28, v12, v16, v17, v18, v19, v20, v21, v22, v23, v24, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_V v28, v12, v18, v19, v20, v21, v22, v23, v24, v25, v26, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_8_2_3_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_2_3_INIT
    HV_PP_N8_COEFFIDX2_H_COEFFIDX3_V_INIT
    HV_PP_N8_COEFFIDX2_H v12, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v13, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v14, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v15, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v16, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v17, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v18, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v19, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v20, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v21, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_V v24, v26, v12, v13, v14, v15, v16, v17, v18, v19, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_V v24, v26, v14, v15, v16, v17, v18, v19, v20, v21, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_H v22, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v23, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v24, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v25, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_V v26, v28, v16, v17, v18, v19, v20, v21, v22, v23, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_V v26, v28, v18, v19, v20, v21, v22, v23, v24, v25, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_8_3_1_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_3_INIT
    HV_PP_N8_COEFFIDX3_H_COEFFIDX1_2_V_INIT
    HV_PP_N8_COEFFIDX3_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v14, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v15, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v16, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v17, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_V v24, v26, v8, v9, v10, v11, v12, v13, v14, v15, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_V v24, v26, v10, v11, v12, v13, v14, v15, v16, v17, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_H v18, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v19, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v20, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v21, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_V v24, v26, v12, v13, v14, v15, v16, v17, v18, v19, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_V v24, v26, v14, v15, v16, v17, v18, v19, v20, v21, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_8_3_2_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_2_3_INIT
    HV_PP_N8_COEFFIDX3_H_COEFFIDX1_2_V_INIT
    HV_PP_N8_COEFFIDX3_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v14, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v15, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v16, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v17, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v18, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_V v24, v26, v8, v9, v10, v11, v12, v13, v14, v15, v16, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_V v24, v26, v10, v11, v12, v13, v14, v15, v16, v17, v18, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_H v19, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v20, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v21, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v22, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_V v24, v26, v12, v13, v14, v15, v16, v17, v18, v19, v20, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_V v24, v26, v14, v15, v16, v17, v18, v19, v20, v21, v22, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_8_3_3_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_3_INIT
    HV_PP_N8_COEFFIDX3_H_COEFFIDX3_V_INIT
    HV_PP_N8_COEFFIDX3_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v14, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v15, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v16, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v17, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_V v24, v26, v8, v9, v10, v11, v12, v13, v14, v15, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_V v24, v26, v10, v11, v12, v13, v14, v15, v16, v17, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_H v18, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v19, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v20, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v21, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_V v24, v26, v12, v13, v14, v15, v16, v17, v18, v19, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_V v24, v26, v14, v15, v16, v17, v18, v19, v20, v21, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc
.endm

HV_PP_8_X_8 4 mf4 mf2 m1
HV_PP_8_X_8 8 mf4 mf2 m1
HV_PP_8_X_8 16 mf2 m1 m2

.macro HV_PP_8_X_16 w e8lmul e16lmul e32lmul
function x265_8_interp_hv_pp_8_\w\()_16_1_1_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_3_INIT
    HV_PP_N8_COEFFIDX1_H_COEFFIDX1_2_V_INIT
    HV_PP_N8_COEFFIDX1_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v14, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v15, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v16, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v17, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_V v24, v26, v8, v9, v10, v11, v12, v13, v14, v15, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_V v24, v26, v10, v11, v12, v13, v14, v15, v16, v17, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_H v18, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v19, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v20, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v21, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_V v24, v26, v12, v13, v14, v15, v16, v17, v18, v19, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_V v24, v26, v14, v15, v16, v17, v18, v19, v20, v21, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_V v24, v26, v16, v17, v18, v19, v20, v21, v8, v9, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_V v24, v26, v18, v19, v20, v21, v8, v9, v10, v11, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v14, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v15, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_V v24, v26, v20, v21, v8, v9, v10, v11, v12, v13, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_V v24, v26, v8, v9, v10, v11, v12, v13, v14, v15, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_16_1_2_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_2_3_INIT
    HV_PP_N8_COEFFIDX1_H_COEFFIDX1_2_V_INIT
    HV_PP_N8_COEFFIDX1_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v14, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v15, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v16, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v17, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v18, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_V v24, v26, v8, v9, v10, v11, v12, v13, v14, v15, v16, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_V v24, v26, v10, v11, v12, v13, v14, v15, v16, v17, v18, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_H v19, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v20, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v21, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v22, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_V v24, v26, v12, v13, v14, v15, v16, v17, v18, v19, v20, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_V v24, v26, v14, v15, v16, v17, v18, v19, v20, v21, v22, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_V v24, v26, v16, v17, v18, v19, v20, v21, v22, v8, v9, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_V v24, v26, v18, v19, v20, v21, v22, v8, v9, v10, v11, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v14, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v15, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_V v24, v26, v20, v21, v22, v8, v9, v10, v11, v12, v13, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_V v24, v26, v22, v8, v9, v10, v11, v12, v13, v14, v15, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_16_1_3_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_3_INIT
    HV_PP_N8_COEFFIDX1_H_COEFFIDX3_V_INIT
    HV_PP_N8_COEFFIDX1_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v14, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v15, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v16, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v17, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_V v24, v26, v8, v9, v10, v11, v12, v13, v14, v15, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_V v24, v26, v10, v11, v12, v13, v14, v15, v16, v17, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_H v18, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v19, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v20, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v21, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_V v24, v26, v12, v13, v14, v15, v16, v17, v18, v19, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_V v24, v26, v14, v15, v16, v17, v18, v19, v20, v21, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_V v24, v26, v16, v17, v18, v19, v20, v21, v8, v9, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_V v24, v26, v18, v19, v20, v21, v8, v9, v10, v11, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_H v14, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX1_H v15, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_V v24, v26, v20, v21, v8, v9, v10, v11, v12, v13, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_V v24, v26, v8, v9, v10, v11, v12, v13, v14, v15, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_16_2_1_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_2_3_INIT
    HV_PP_N8_COEFFIDX2_H_COEFFIDX1_2_V_INIT
    HV_PP_N8_COEFFIDX2_H v12, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v13, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v14, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v15, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v16, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v17, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v18, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v19, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v20, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v21, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_V v24, v26, v12, v13, v14, v15, v16, v17, v18, v19, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_V v24, v26, v14, v15, v16, v17, v18, v19, v20, v21, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_H v22, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v23, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v24, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v25, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_V v26, v28, v16, v17, v18, v19, v20, v21, v22, v23, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_V v26, v28, v18, v19, v20, v21, v22, v23, v24, v25, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_H v12, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v13, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v14, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v15, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_V v26, v28, v20, v21, v22, v23, v24, v25, v12, v13, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_V v26, v28, v22, v23, v24, v25, v12, v13, v14, v15, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_H v16, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v17, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v18, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v19, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_V v26, v28, v24, v25, v12, v13, v14, v15, v16, v17, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_V v26, v28, v12, v13, v14, v15, v16, v17, v18, v19, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_16_2_2_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_2_3_INIT
    HV_PP_N8_COEFFIDX2_H_COEFFIDX1_2_V_INIT
    HV_PP_N8_COEFFIDX2_H v12, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v13, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v14, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v15, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v16, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v17, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v18, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v19, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v20, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v21, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v22, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_V v24, v26, v12, v13, v14, v15, v16, v17, v18, v19, v20, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_V v24, v26, v14, v15, v16, v17, v18, v19, v20, v21, v22, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_H v12, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v13, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v14, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v15, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_V v24, v26, v16, v17, v18, v19, v20, v21, v22, v12, v13, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_V v24, v26, v18, v19, v20, v21, v22, v12, v13, v14, v15, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_H v16, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v17, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v18, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v19, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_V v24, v26, v20, v21, v22, v12, v13, v14, v15, v16, v17, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_V v24, v26, v22, v12, v13, v14, v15, v16, v17, v18, v19, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_H v20, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v21, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v22, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v12, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_V v24, v26, v13, v14, v15, v16, v17, v18, v19, v20, v21, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_V v24, v26, v15, v16, v17, v18, v19, v20, v21, v22, v12, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_16_2_3_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_2_3_INIT
    HV_PP_N8_COEFFIDX2_H_COEFFIDX3_V_INIT
    HV_PP_N8_COEFFIDX2_H v12, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v13, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v14, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v15, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v16, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v17, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v18, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v19, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v20, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v21, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_V v24, v26, v12, v13, v14, v15, v16, v17, v18, v19, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_V v24, v26, v14, v15, v16, v17, v18, v19, v20, v21, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_H v22, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v23, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v24, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v25, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_V v26, v28, v16, v17, v18, v19, v20, v21, v22, v23, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_V v26, v28, v18, v19, v20, v21, v22, v23, v24, v25, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_H v12, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v13, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v14, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v15, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_V v26, v28, v20, v21, v22, v23, v24, v25, v12, v13, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_V v26, v28, v22, v23, v24, v25, v12, v13, v14, v15, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_H v16, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v17, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_H v18, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX2_H v19, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_V v26, v28, v24, v25, v12, v13, v14, v15, v16, v17, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_V v26, v28, v12, v13, v14, v15, v16, v17, v18, v19, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_16_3_1_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_3_INIT
    HV_PP_N8_COEFFIDX3_H_COEFFIDX1_2_V_INIT
    HV_PP_N8_COEFFIDX3_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v14, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v15, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v16, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v17, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_V v24, v26, v8, v9, v10, v11, v12, v13, v14, v15, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_V v24, v26, v10, v11, v12, v13, v14, v15, v16, v17, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_H v18, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v19, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v20, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v21, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_V v24, v26, v12, v13, v14, v15, v16, v17, v18, v19, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_V v24, v26, v14, v15, v16, v17, v18, v19, v20, v21, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_H v22, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v23, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_V v24, v26, v16, v17, v18, v19, v20, v21, v22, v23, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_V v24, v26, v18, v19, v20, v21, v22, v23, v8, v9, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX1_V v24, v26, v20, v21, v22, v23, v8, v9, v10, v11, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX1_V v24, v26, v22, v23, v8, v9, v10, v11, v12, v13, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_16_3_2_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_2_3_INIT
    HV_PP_N8_COEFFIDX3_H_COEFFIDX1_2_V_INIT
    HV_PP_N8_COEFFIDX3_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v14, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v15, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v16, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v17, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v18, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_V v24, v26, v8, v9, v10, v11, v12, v13, v14, v15, v16, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_V v24, v26, v10, v11, v12, v13, v14, v15, v16, v17, v18, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_H v19, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v20, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v21, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v22, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_V v24, v26, v12, v13, v14, v15, v16, v17, v18, v19, v20, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_V v24, v26, v14, v15, v16, v17, v18, v19, v20, v21, v22, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_V v24, v26, v16, v17, v18, v19, v20, v21, v22, v8, v9, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_V v24, v26, v18, v19, v20, v21, v22, v8, v9, v10, v11, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v14, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v15, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX2_V v24, v26, v20, v21, v22, v8, v9, v10, v11, v12, v13, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX2_V v24, v26, v22, v8, v9, v10, v11, v12, v13, v14, v15, v30, v31, \e8lmul, \e16lmul, \e32lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc

function x265_8_interp_hv_pp_8_\w\()_16_3_3_rvv, export=0
    PUSH_STACK
    COEFFIDX_1_3_INIT
    HV_PP_N8_COEFFIDX3_H_COEFFIDX3_V_INIT
    HV_PP_N8_COEFFIDX3_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v14, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v15, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v16, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v17, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_V v24, v26, v8, v9, v10, v11, v12, v13, v14, v15, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_V v24, v26, v10, v11, v12, v13, v14, v15, v16, v17, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_H v18, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v19, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v20, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v21, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_V v24, v26, v12, v13, v14, v15, v16, v17, v18, v19, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_V v24, v26, v14, v15, v16, v17, v18, v19, v20, v21, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_H v22, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v23, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v8, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v9, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_V v24, v26, v16, v17, v18, v19, v20, v21, v22, v23, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_V v24, v26, v18, v19, v20, v21, v22, v23, v8, v9, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_H v10, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v11, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_H v12, v31, \e8lmul, \e16lmul, \w, a1, a0, s3; HV_PP_N8_COEFFIDX3_H v13, v31, \e8lmul, \e16lmul, \w, a1, a0, s3;
    HV_PP_N8_COEFFIDX3_V v24, v26, v20, v21, v22, v23, v8, v9, v10, v11, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    HV_PP_N8_COEFFIDX3_V v24, v26, v22, v23, v8, v9, v10, v11, v12, v13, v30, v31, \e8lmul, \e16lmul, \w, a3, a2, s2
    POP_STACK
    ret
endfunc
.endm

HV_PP_8_X_16 4 mf4 mf2 m1
HV_PP_8_X_16 8 mf4 mf2 m1
HV_PP_8_X_16 12 mf2 m1 m2
HV_PP_8_X_16 16 mf2 m1 m2

.macro HV_PP_8_X_X_FUNC1 w h
function PFX(interp_hv_pp_8_\w\()x\h\()_v256_rvv), export=1
    csrwi          vxrm, 0
    PUSH_STACK
    li             s2, 1
    li             s3, 2
    li             s4, 3
    beq            a4, s2, idxX1_\w\()_\h\()
    beq            a4, s3, idxX2_\w\()_\h\()
    beq            a4, s4, idxX3_\w\()_\h\()
    j              exit_\w\()_\h\()
idxX1_\w\()_\h\():
    beq            a5, s2, idxX1_idxY1_\w\()_\h\()
    beq            a5, s3, idxX1_idxY2_\w\()_\h\()
    beq            a5, s4, idxX1_idxY3_\w\()_\h\()
    j              exit_\w\()_\h\()
idxX1_idxY1_\w\()_\h\():
    call           x265_8_interp_hv_pp_8_\w\()_\h\()_1_1_rvv
    j              exit_\w\()_\h\()
idxX1_idxY2_\w\()_\h\():
    call           x265_8_interp_hv_pp_8_\w\()_\h\()_1_2_rvv
    j              exit_\w\()_\h\()
idxX1_idxY3_\w\()_\h\():
    call           x265_8_interp_hv_pp_8_\w\()_\h\()_1_3_rvv
    j              exit_\w\()_\h\()
idxX2_\w\()_\h\():
    beq            a5, s2, idxX2_idxY1_\w\()_\h\()
    beq            a5, s3, idxX2_idxY2_\w\()_\h\()
    beq            a5, s4, idxX2_idxY3_\w\()_\h\()
    j              exit_\w\()_\h\()
idxX2_idxY1_\w\()_\h\():
    call           x265_8_interp_hv_pp_8_\w\()_\h\()_2_1_rvv
    j              exit_\w\()_\h\()
idxX2_idxY2_\w\()_\h\():
    call           x265_8_interp_hv_pp_8_\w\()_\h\()_2_2_rvv
    j              exit_\w\()_\h\()
idxX2_idxY3_\w\()_\h\():
    call           x265_8_interp_hv_pp_8_\w\()_\h\()_2_3_rvv
    j              exit_\w\()_\h\()
idxX3_\w\()_\h\():
    beq            a5, s2, idxX3_idxY1_\w\()_\h\()
    beq            a5, s3, idxX3_idxY2_\w\()_\h\()
    beq            a5, s4, idxX3_idxY3_\w\()_\h\()
    j              exit_\w\()_\h\()
idxX3_idxY1_\w\()_\h\():
    call           x265_8_interp_hv_pp_8_\w\()_\h\()_3_1_rvv
    j              exit_\w\()_\h\()
idxX3_idxY2_\w\()_\h\():
    call           x265_8_interp_hv_pp_8_\w\()_\h\()_3_2_rvv
    j              exit_\w\()_\h\()
idxX3_idxY3_\w\()_\h\():
    call           x265_8_interp_hv_pp_8_\w\()_\h\()_3_3_rvv
exit_\w\()_\h\():
    POP_STACK
    ret
endfunc
.endm

.macro HV_PP_8_X_X_FUNC2 w h iw ih shift
function PFX(interp_hv_pp_8_\w\()x\h\()_v256_rvv), export=1
    PUSH_STACK
    sd             a0, 32(sp)
    sd             a1, 40(sp)
    sd             a2, 48(sp)
    sd             a3, 56(sp)
    call           PFX(interp_hv_pp_8_\iw\()x\ih\()_v256_rvv)
    ld             a0, 32(sp)
    ld             a1, 40(sp)
    ld             a2, 48(sp)
    ld             a3, 56(sp)
    slli           s2, a1, \shift
    slli           s3, a3, \shift
    add            a0, a0, s2
    add            a2, a2, s3
    call           PFX(interp_hv_pp_8_\iw\()x\ih\()_v256_rvv)
    POP_STACK
    ret
endfunc
.endm

.macro HV_PP_8_X_X_FUNC3 w h iw ih base
function PFX(interp_hv_pp_8_\w\()x\h\()_v256_rvv), export=1
    PUSH_STACK
    sd             a0, 32(sp)
    sd             a1, 40(sp)
    sd             a2, 48(sp)
    sd             a3, 56(sp)
    call           PFX(interp_hv_pp_8_\iw\()x\ih\()_v256_rvv)
    ld             a0, 32(sp)
    ld             a1, 40(sp)
    ld             a2, 48(sp)
    ld             a3, 56(sp)
    addi           a0, a0, \base
    addi           a2, a2, \base
    call           PFX(interp_hv_pp_8_\iw\()x\ih\()_v256_rvv)
    POP_STACK
    ret
endfunc
.endm

HV_PP_8_X_X_FUNC1 4 4
HV_PP_8_X_X_FUNC1 4 8
HV_PP_8_X_X_FUNC1 4 16
HV_PP_8_X_X_FUNC1 12 16
HV_PP_8_X_X_FUNC1 8 4
HV_PP_8_X_X_FUNC1 8 8
HV_PP_8_X_X_FUNC1 8 16
HV_PP_8_X_X_FUNC2 8 32 8 16 4
HV_PP_8_X_X_FUNC1 16 4
HV_PP_8_X_X_FUNC1 16 8
HV_PP_8_X_X_FUNC1 16 16
HV_PP_8_X_X_FUNC2 16 32 16 16 4
HV_PP_8_X_X_FUNC2 16 64 16 32 5
HV_PP_8_X_X_FUNC3 32 8 16 8 16
HV_PP_8_X_X_FUNC3 32 16 16 16 16
HV_PP_8_X_X_FUNC2 32 32 32 16 4
HV_PP_8_X_X_FUNC2 32 64 32 32 5
HV_PP_8_X_X_FUNC3 64 16 32 16 32
HV_PP_8_X_X_FUNC3 64 32 32 32 32
HV_PP_8_X_X_FUNC3 64 64 32 64 32

function PFX(interp_hv_pp_8_16x12_v256_rvv), export=1
    PUSH_STACK
    sd             a0, 32(sp)
    sd             a1, 40(sp)
    sd             a2, 48(sp)
    sd             a3, 56(sp)
    call           PFX(interp_hv_pp_8_16x4_v256_rvv)
    ld             a0, 32(sp)
    ld             a1, 40(sp)
    ld             a2, 48(sp)
    ld             a3, 56(sp)
    slli           s2, a1, 2
    slli           s3, a3, 2
    add            a0, a0, s2
    add            a2, a2, s3
    call           PFX(interp_hv_pp_8_16x8_v256_rvv)
    POP_STACK
    ret
endfunc

function PFX(interp_hv_pp_8_24x32_v256_rvv), export=1
    PUSH_STACK
    sd             a0, 32(sp)
    sd             a1, 40(sp)
    sd             a2, 48(sp)
    sd             a3, 56(sp)
    call           PFX(interp_hv_pp_8_16x32_v256_rvv)
    ld             a0, 32(sp)
    ld             a1, 40(sp)
    ld             a2, 48(sp)
    ld             a3, 56(sp)
    addi           a0, a0, 16
    addi           a2, a2, 16
    call           PFX(interp_hv_pp_8_8x32_v256_rvv)
    POP_STACK
    ret
endfunc

function PFX(interp_hv_pp_8_32x24_v256_rvv), export=1
    PUSH_STACK
    sd             a0, 32(sp)
    sd             a1, 40(sp)
    sd             a2, 48(sp)
    sd             a3, 56(sp)
    call           PFX(interp_hv_pp_8_32x8_v256_rvv)
    ld             a0, 32(sp)
    ld             a1, 40(sp)
    ld             a2, 48(sp)
    ld             a3, 56(sp)
    slli           s2, a1, 3
    slli           s3, a3, 3
    add            a0, a0, s2
    add            a2, a2, s3
    call           PFX(interp_hv_pp_8_32x16_v256_rvv)
    POP_STACK
    ret
endfunc

function PFX(interp_hv_pp_8_48x64_v256_rvv), export=1
    PUSH_STACK
    sd             a0, 32(sp)
    sd             a1, 40(sp)
    sd             a2, 48(sp)
    sd             a3, 56(sp)
    call           PFX(interp_hv_pp_8_16x64_v256_rvv)
    ld             a0, 32(sp)
    ld             a1, 40(sp)
    ld             a2, 48(sp)
    ld             a3, 56(sp)
    addi           a0, a0, 16
    addi           a2, a2, 16
    call           PFX(interp_hv_pp_8_32x64_v256_rvv)
    POP_STACK
    ret
endfunc

function PFX(interp_hv_pp_8_64x48_v256_rvv), export=1
    PUSH_STACK
    sd             a0, 32(sp)
    sd             a1, 40(sp)
    sd             a2, 48(sp)
    sd             a3, 56(sp)
    call           PFX(interp_hv_pp_8_64x16_v256_rvv)
    ld             a0, 32(sp)
    ld             a1, 40(sp)
    ld             a2, 48(sp)
    ld             a3, 56(sp)
    slli           s2, a1, 4
    slli           s3, a3, 4
    add            a0, a0, s2
    add            a2, a2, s3
    call           PFX(interp_hv_pp_8_64x32_v256_rvv)
    POP_STACK
    ret
endfunc

#endif
