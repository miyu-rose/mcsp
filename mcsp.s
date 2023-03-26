;========================================================================================
;
; mcsp version 1.00 by �͂� (Hau) �� �݂� (miyu rose)
;
;          mcsp Designer    �݂� (miyu rose)
;               Programmer  X68KBBS�FX68K0001
;                           Twitter�F@arith_rose
;
;          Special Adviser  �͂� (Hau) ����
;          mcsp Tester      X68KBBS�FX68K0024
;                           Twitter�F@Hau_oli
;
;========================================================================================

    .cpu    68000

    .include    doscall.mac
    .include    iocscall.mac

.ifndef _MACS
_MACS       .equ    $D0                         ; macsdrv.x
.endif

.ifndef _MALLOC3
_MALLOC3:   .equ    $ff90                       ; 060turbo.sys
.endif

;=========================================================================================

    .text
    .even

;=========================================================================================
; �v���O�����J�n
;   a0   �� �������Ǘ��|�C���^�̃A�h���X
;   a1   �� ���̃������Ǘ��|�C���^�̃A�h���X�i�v���O�����I�[�̃A�h���X+1�j
;   a2   �� �����̕����񒷁i����������|�C���^-1�j
;-----------------------------------------------------------------------------------------
main:                                           ; �{�v���O�����̊J�n�A�h���X
    lea.l   mysp,sp                             ; �X�^�b�N�̈�����O�Ŋm��

;-----------------------------------------------------------------------------------------
; MACS�f�[�^�̍Đ��Ƀ��[�J��������/�n�C�������𗘗p�ł��Ȃ��ꍇ�ɔ�����
; �{�v���O�����̒���̃������i���C���������j�𗘗p�\�ȏ�Ԃɂ��Ă���
;   a0   �� �������Ǘ��|�C���^�̃A�h���X
;        �F �v���Z�X�Ǘ��|�C���^�̐擪�A�h���X
;   a1   �� ���̃������Ǘ��|�C���^�̃A�h���X�i�v���O�����I�[�̃A�h���X+1�j
;        �F �v���Z�X�Ǘ��̈�{�v���O�����̃T�C�Y
;-----------------------------------------------------------------------------------------

    lea     $10(a0),a0                          ; a0 �Ƀ������u���b�N�`�F�[�����i$10 bytes�j���X�L�b�v���ăv���Z�X�Ǘ��|�C���^�̐擪�A�h���X���擾
    sub.l   a0,a1                               ; a1 �Ƀv���Z�X�Ǘ��̈�{�v���O�����̃T�C�Y���擾

    move.l  a1,-(sp)                            ; �v���Z�X�Ǘ��̈�{�v���O�����̃T�C�Y
    move.l  a0,-(sp)                            ; �v���Z�X�Ǘ��|�C���^�̐擪�A�h���X
    DOS     _SETBLOCK                           ; �v���Z�X�Ǘ��|�C���^�̐擪�A�h���X���玟�̃������Ǘ��|�C���^���O�܂ł̃��������m��
                                                ;  �� ���ʓI�ɁA�{�v���O�����̒���̃��������m�ۉ\�ȏ�ԂƂȂ�܂�
    addq.l  #8,sp                               ;
    tst.l   d0                                  ; _SETBLOCK �̃G���[�R�[�h��
    bpl     99f                                 ;  ����I���Ȃ�Ύ���

    pea.l   err_Human68k                        ; Human68k �̒v���I�ȃG���[���������Ă��܂��G���[�i�\�����ʓ䌻�ہj
    bra     error                               ; �G���[�I��

99:

;-----------------------------------------------------------------------------------------
; �^�C�g���\��
;   mlib_title     �� �^�C�g��������̃A�h���X
;   mlib_version   �� �o�[�W����������̃A�h���X
;   mlib_by        �� by������̃A�h���X
;   mlib_author    �� ��ҕ�����̃A�h���X
;-----------------------------------------------------------------------------------------

    bsr       disp_Title                        ; �^�C�g���\��

;-----------------------------------------------------------------------------------------
; ��������
;   d0.l �F �e���|�����i��Ɉ��������t�F�b�`�p�j
;   a2   �� ���̃������Ǘ��|�C���^�̃A�h���X�i�v���O�����I�[�̃A�h���X+1�j
;        �F ����������|�C���^
;   a6   �F �t�@�C���p�X�̃t�F�b�`�����i�[��|�C���^
;-----------------------------------------------------------------------------------------

    addq.l  #1,a2                               ; a2 �Ɉ���������̐擪�A�h���X���擾�i�����̕����񒷂��X�L�b�v�j
    lea.l   buf_filepath,a6                     ; a6 �Ƀt�@�C���p�X�̐擪�A�h���X���擾
    move.b  #$ff, buf_filepath_end              ; �t�@�C���p�X�I�[�}�[�J�[��ݒu

check_arg:
    move.b  (a2)+,d0                            ; �����������t�F�b�`
    cmpi.b  #' ',d0                             ; ' ' �Ɣ�r����
    beq     check_arg                           ;  �����Ȃ�X�L�b�v

    tst.b   d0                                  ; �I�[�����Ɣ�r����
    beq     99f                                 ;  �����Ȃ�����`�F�b�N�I��

    cmpi.b  #'-',d0                             ; '-' �Ɣ�r����
    beq     check_arg_option                    ;  �����Ȃ�I�v�V���������`�F�b�N��

    bra     arg_filepath                        ; �t�@�C���p�X������

check_arg_option:
    move.b  (a2)+,d0                            ; ���̃I�v�V���������������t�F�b�`
    tst.b   d0                                  ; �I�[�����Ɣ�r����
    beq     99f                                 ;  �����Ȃ�����`�F�b�N�I��

    ori.b   #$20,d0                             ; �A���t�@�x�b�g��������
    cmpi.b  #'i',d0                             ; 'i' �Ɣ�r����
    beq     arg_option_i                        ;  �����Ȃ� i �I�v�V����������

    cmpi.b  #' ',d0                             ; ' ' �Ɣ�r����
    beq     check_arg                           ;  �����Ȃ玟�̈�����

    bra     check_arg_option                    ; ���̃I�v�V�������������ցi���[�v�j

arg_option_i:
    bset.b  #0,flg_option                       ; i �t���O�𗧂Ă�
    bra     check_arg_option                    ; ���̃I�v�V�������������ցi���[�v�j

arg_filepath:
    move.b  d0,(a6)+                            ; �t�@�C���p�X�֒ǋL
    tst.b   (a6)                                ; ���̃t�@�C���p�X�i�[�悪
    beq     @f                                  ;  $00 �Ȃ�܂��������߂�̂Ŏ���

    clr.b   (a6)                                ; �p�X���̏���ɓ��B�����̂ŏI�[���� $00 �����������
    bra     99f                                 ;   �����I�Ɉ����`�F�b�N�I��
@@:
    move.b  (a2)+,d0                            ; ���̈����������t�F�b�`
    cmpi.b  #' ',d0                             ; ' ' �Ɣ�r����
    beq     99f                                 ;  �����Ȃ�t�@�C���p�X�I�[�Ȃ̂ň����`�F�b�N�I��
    tst.b   d0                                  ; �I�[�����Ɣ�r����
    beq     99f                                 ;  �����Ȃ�t�@�C���p�X�I�[�Ȃ̂ň����`�F�b�N�I��
    bra     arg_filepath                        ; �t�@�C���p�X�֒ǋL�i���[�v�j

99:

;-----------------------------------------------------------------------------------------
; MACSDATA�t�@�C���`�F�b�N
;   d0.l �F �e���|�����i���DOSCALL�Ԃ�l�j
;   d6.l �F �t�@�C���T�C�Y
;   d7.l �F �t�@�C���n���h��
;   a1   �F MACSDATA�̃`�F�b�N�p�o�b�t�@�A�h���X
;-----------------------------------------------------------------------------------------

check_file:
    move.b  buf_filepath,d0                     ; d0 �Ƀt�@�C���p�X�P�����ڂ��擾
    tst.b   d0                                  ; ���̒l��
    bne     @f                                  ;  $00 �łȂ���΃t�@�C���p�X���w�肳��Ă���̂Ŏ���

    pea.l   mes_help                            ; �t�@�C���p�X���w�肳��Ă��Ȃ��̂Ńw���v
    bra     error                               ; �G���[�I��
@@:
    clr.w   -(sp)                               ; READ���[�h��
    pea.l   buf_filepath                        ;  �w�肳�ꂽ�t�@�C����
    DOS     _OPEN                               ;  �J��
    addq.l  #6,sp
    move.l  d0,d7                               ; �t�@�C���n���h���� d7 �ɕۑ�
    bpl     @f                                  ; ���̒l�łȂ���ΐ���Ȃ̂Ŏ���

    pea.l   err_fileopen                        ; �t�@�C�����J���܂���G���[
    bra     error                               ; �G���[����
@@:

check_filesize:
    move.w  #2,-(sp)                            ; ���[�h �t�@�C���I�[����
    clr.l   -(sp)                               ; �I�t�Z�b�g 0
    move.w  d7,-(sp)                            ; �t�@�C���n���h��
    DOS     _SEEK                               ; �V�[�N���܂��id0 �Ƀt�@�C���擪����̃I�t�Z�b�g = �t�@�C���T�C�Y���Ԃ�܂��j
    addq.l  #8,sp                               ; SP ��߂��܂�
    move.l  d0,d6                               ; �t�@�C���T�C�Y�� d6 �֕ۑ�
    bpl     @f                                  ; ���̒l�łȂ���ΐ���Ȃ̂Ŏ���

    pea.l   err_fileseek                        ; �t�@�C�������Ă��܂��G���[
    bra     error                               ; �G���[����
@@:
    cmp.l   #18,d6                              ; �ŏ���MACS�t�@�C���T�C�Y 18Bytes �Ɣ�r����
    bpl     @f                                  ; �傫����Ζ��Ȃ�

    pea.l   err_notmacs                         ; MACS�t�@�C������Ȃ���G���[
    bra     error                               ; �G���[����
@@:
    clr.w   -(sp)                               ; ���[�h �t�@�C���擪����
    clr.l   -(sp)                               ; �I�t�Z�b�g 0
    move.w  d7,-(sp)                            ; �t�@�C���n���h��
    DOS     _SEEK                               ; �V�[�N���܂�
    addq.l  #8,sp                               ; SP ��߂��܂�
    tst.l   d0                                  ; d0 �̒l��
    bpl     @f                                  ;  ���̒l�łȂ���ΐ���Ȃ̂Ŏ���

    pea.l   err_fileseek                        ; �t�@�C�������Ă��܂��G���[
    bra     error                               ; �G���[����
@@:

check_macsdata:
    lea.l   buf_macsmagic,a1                    ; MACS�f�[�^�̃}�W�b�N���[�h 'MACSDATA' �`�F�b�N�p�o�b�t�@

    move.l  #$10,-(sp)                          ; �ǂݍ��ރT�C�Y $10 Bytes
    pea.l   (a1)                                ; �ǂݍ��݃o�b�t�@
    move.w  d7,-(sp)                            ; �t�@�C���n���h��
    DOS     _READ                               ; �ǂݍ��݂܂�
    lea.l   10(sp),sp                           ; SP ��߂��܂�
    tst.l   d0                                  ; �ǂݍ��񂾃T�C�Y��
    bpl     @f                                  ;  ���̒l�łȂ���ΐ���Ȃ̂Ŏ���

    pea.l   err_fileread                        ; �t�@�C����ǂݍ��݂ł��܂���ł����G���[
    bra     error                               ; �G���[����
@@:

check_magicword:
    cmp.l   #'MACS',(a1)                        ; 'MACS' �Ɣ�r����
    beq     @f                                  ;  �����Ȃ玟��

    pea.l   err_notmacs                         ; MACS�t�@�C������Ȃ���G���[�\��
    bra     error                               ; �G���[����
@@:
    cmp.l   #'DATA',4(a1)                       ; 'DATA' �Ɣ�r����
    beq     @f                                  ;  �����Ȃ玟��

    pea.l   err_notmacs                         ; MACS�t�@�C������Ȃ���G���[�\��
    bra     error                               ; �G���[����
@@:

;-----------------------------------------------------------------------------------------
; MACSDATA���\��
;   d0.l �F �e���|�����iDOSCALL�Ԃ�l�j
;   d1.l �F �e���|����
;   d4.w �F MACSDATA�o�[�W����
;   d7.l �F �t�@�C���n���h��
;   a1   �F MACSDATA�̃`�F�b�N�p�o�b�t�@�A�h���X
;-----------------------------------------------------------------------------------------

print_dataversion:
    pea.l   mes_dataversion                     ; 'DataVersion:'
    DOS     _PRINT                              ;  ��\�������
    addq.l  #4,sp                               ; SP ��߂��܂�

    move.w #$0002,-(sp)                         ; ���F��
    move.w #$0002,-(sp)                         ;  ��������
    DOS    _CONCTRL                             ;   �ɐݒ肷���
    addq.l #4,sp                                ; SP ��߂��܂�

    move.w 8(a1),d4                             ; d4 �� MACSDATA�o�[�W�������擾
    move.b 8(a1),d0                             ; d0 �� MACSDATA���C���o�[�W�������擾
    lsr.b  #4,d0                                ; d0 �� MACSDATA���C���o�[�W�����̂P���ڂ��擾
    beq    @f                                   ; ���C���o�[�W�����P���ڂ� 0 ��������X�L�b�v

    bsr    mlib_puthex                          ; ���C���o�[�W�����P���ڂ�\�������
@@:
    move.b 8(a1),d0                             ; d0 �� MACSDATA���C���o�[�W�������擾
    and.b  #$0f,d0                              ; d0 �� MACSDATA���C���o�[�W�����̂Q���ڂ��擾
    bsr    mlib_puthex                          ; ���C���o�[�W�����Q���ڂ�\�������

    move.w #'.',-(sp)                           ; '.' ��
    DOS    _PUTCHAR                             ;  �\�������
    addq.l #2,sp                                ; SP ��߂��܂�

    move.b d4,d0                                ; d0 �� MACSDATA�}�C�i�[�o�[�W�������擾
    lsr.b  #4,d0                                ; d0 �� MACSDATA�}�C�i�[�o�[�W�����̂P���ڂ��擾
    bsr    mlib_puthex                          ; �}�C�i�[�o�[�W�����P���ڂ�\�������

    move.b d4,d0                                ; d0 �� MACSDATA�}�C�i�[�o�[�W�������擾
    and.b  #$0f,d0                              ; d0 �� MACSDATA�}�C�i�[�o�[�W�����̂Q���ڂ��擾
    bsr    mlib_puthex                          ; �}�C�i�[�o�[�W�����Q���ڂ�\�������
    move.w #$0003,-(sp)                         ; ���F��
    move.w #$0002,-(sp)                         ;  ��������
    DOS    _CONCTRL                             ;   �ɐݒ肷���
    addq.l #4,sp                                ; SP ��߂��܂�

    pea.l  mes_filesize                         ; 'FileSize:'��
    DOS    _PRINT                               ;  �\�������
    addq.l #4,sp                                ; SP ��߂��܂�

    move.w #$0002,-(sp)                         ; ���F��
    move.w #$0002,-(sp)                         ;  ��������
    DOS    _CONCTRL                             ;   �ɐݒ肷���
    addq.l #4,sp                                ; SP ��߂��܂�

    move.l 10(a1),d0                            ; �t�@�C���T�C�Y���擾
    cmp.l  #$400,d0                             ; 1024(1KB) �Ɣ�r����
    bge    @f                                   ; �傫����Ύ���

    bsr    mlib_printdec                        ; �\�i���\�������

    pea.l  mes_unit_B                           ; '[B]' ��
    DOS    _PRINT                               ;  �\�������
    addq.l #4,sp                                ; SP ��߂��܂�

    bra    9f                                   ; ����
@@:
    lsr.l  #8,d0                                ; d0.l �� 8bit�E�V�t�g
    lsr.l  #2,d0                                ; d0.l �� 2bit�E�V�t�g(1024�Ŋ��邽�߂Ɍv10bit�E�V�t�g)
    cmp.l  #$400,d0                             ; 1024(1MB) �Ɣ�r����
    bge    @f                                   ; �傫����Ύ���

    bsr    mlib_printdec                        ; �\�i���\�������

    pea.l  mes_unit_KB                          ; '[KB]' ��
    DOS    _PRINT                               ;  �\�������
    addq.l #4,sp                                ; SP ��߂��܂�

    bra    9f                                   ; ����
@@:
    lsr.l  #8,d0                                ; d0.l �� 8bit�E�V�t�g
    lsr.l  #2,d0                                ; d0.l �� 2bit�E�V�t�g(1024�Ŋ��邽�߂Ɍv10bit�E�V�t�g)

    bsr    mlib_printdec                        ; �\�i���\�������

    pea.l  mes_unit_MB                          ; '[MB]' ��
    DOS    _PRINT                               ;  �\�������
    addq.l #4,sp                                ; SP ��߂��܂�
9:
    move.w #$0003,-(sp)                         ; ���F�́i���W���ݒ�ɖ߂��j
    move.w #$0002,-(sp)                         ;  ��������
    DOS    _CONCTRL                             ;   �ɐݒ肷���
    pea.l  mlib_crlf                            ; ���s��
    DOS    _PRINT                               ;  �\�������
    addq.l #8,sp                                ; SP ��߂��܂�

    bra    @f                                   ; ����

read_command:
    move.l  #$2,-(sp)                           ; �ǂݍ��ރT�C�Y $2 Bytes
    pea.l   buf_command                         ; �ǂݍ��݃o�b�t�@
    move.w  d7,-(sp)                            ; �t�@�C���n���h��
    DOS     _READ                               ; �ǂݍ��݂܂�
    lea.l   10(sp),sp                           ; SP ��߂��܂�
    tst.l   d0                                  ; �ǂݍ��񂾃T�C�Y��
    bpl     @f                                  ;  ���̒l�łȂ���ΐ���Ȃ̂Ŏ���

    pea.l   err_fileread                        ; �t�@�C����ǂݍ��݂ł��܂���ł����G���[
    bra     error                               ; �G���[����
@@:

check_command:
    move.w buf_command,d0                       ; d0 �ɓǂݍ���MACS�R�}���h���擾

    cmp.w  #$0001,d0                            ; $0001�i�������j�Ɣ�r����
    beq    read_command                         ;  �����Ȃ�X�L�b�v���Ď��̃R�}���h��

    cmp.w  #$002C,d0                            ; $002C�i�R�����g�j�Ɣ�r����
    beq    read_commentsize                     ;  �����Ȃ�R�����g�\����

    bra    99f                                  ; ����ȊO�Ȃ�f�[�^���Ȃ̂ŕ\���I���

read_commentsize:
    move.l  #$2,-(sp)                           ; �ǂݍ��ރT�C�Y $2 Bytes
    pea.l   buf_command                         ; �ǂݍ��݃o�b�t�@
    move.w  d7,-(sp)                            ; �t�@�C���n���h��
    DOS     _READ                               ; �ǂݍ��݂܂�
    lea.l   10(sp),sp                           ; SP ��߂��܂�
    tst.l   d0                                  ; �ǂݍ��񂾃T�C�Y��
    bpl     @f                                  ;  ���̒l�łȂ���ΐ���Ȃ̂Ŏ���

    pea.l   err_fileread                        ; �t�@�C����ǂݍ��݂ł��܂���ł����G���[
    bra     error                               ; �G���[����
@@:
    clr.l   d1                                  ; d1 ��������
    move.w  buf_command,d1                      ; d1 �ɃR�����g�T�C�Y���擾
    move.l  d1,d0                               ; d0 �ɃR�����g�T�C�Y���擾
    cmp.w   #$00ff,d0                           ; $ff(255) Bytes �Ɣ�r����
    ble     @f                                  ;  �ȉ��Ȃ玟��

    move.w  #$00ff,d0                           ; �����I�� $ff(255) Bytes �őł��؂�
@@:

read_comment:
    move.l  d0,-(sp)                            ; �ǂݍ��ރT�C�Y
    pea.l   buf_comment                         ; �ǂݍ��݃o�b�t�@
    move.w  d7,-(sp)                            ; �t�@�C���n���h��
    DOS     _READ                               ; �ǂݍ��݂܂�
    lea.l   10(sp),sp                           ; SP ��߂��܂�
    tst.l   d0                                  ; �ǂݍ��񂾃T�C�Y��
    bpl     @f                                  ;  ���̒l�łȂ���ΐ���Ȃ̂Ŏ���

    pea.l   err_fileread                        ; �t�@�C����ǂݍ��݂ł��܂���ł����G���[
    bra     error                               ; �G���[����
@@:
    sub.l   d0,d1                               ; d1 -= d0
    beq     @f                                  ; �����Ȃ��i�R�����g�T�C�Y�� 255 Bytes �ȓ��j�Ȃ�X�L�b�v

    move.w  #1,-(sp)                            ; ���[�h �t�@�C�����݈ʒu����
    move.l  d1,-(sp)                            ; �I�t�Z�b�g
    move.w  d7,-(sp)                            ; �t�@�C���n���h��
    DOS     _SEEK                               ; �V�[�N���܂�
    addq.l  #8,sp                               ; SP ��߂��܂�
    move.l  d0,d6                               ; �t�@�C���T�C�Y�� d6 �֕ۑ�
    bpl     @f                                  ; ���̒l�łȂ���ΐ���Ȃ̂Ŏ���

    pea.l   err_fileseek                        ; �t�@�C�������Ă��܂��G���[
    bra     error                               ; �G���[����
@@:

print_comment:
    pea.l   buf_comment                         ; �R�����g��
    DOS     _PRINT                              ;  �\�������
    pea.l   mlib_crlf                           ; ���s��
    DOS     _PRINT                              ;  �\�������
    addq.l  #8,sp                               ; SP ��߂��܂�

    bra     read_command                        ; ����MACS�R�}���h���擾

99:
    pea.l  mlib_crlf                            ; ���s��
    DOS    _PRINT                               ;  �\�������
    addq.l #4,sp                                ; SP ��߂��܂�

    btst.b #0,flg_option                        ; i �I�v�V������
    bne    EXIT                                 ; �����Ă����炱���ł����܂�

;-----------------------------------------------------------------------------------------
; MACSDRV �̏풓�`�F�b�N
;   d0.l �F �e���|����
;   d4.w �� MACSDATA�o�[�W����
;   d5.w �F MACSDRV �o�[�W����
;   a1   �F IOCS $D0 (_MACS) �̃x�N�^�A�h���X+2�imacsdrv ���풓����Ă�����'MACSIOCS'���i�[����Ă���͂��j
;-----------------------------------------------------------------------------------------

check_MACSDRV:
    lea.l   $01d0*4.w,a1                        ; a1 �� IOCS $D0 (_MACS) �̃x�N�^�A�h���X���i�[����Ă���x�N�^�e�[�u���̃A�h���X���擾
    IOCS    _B_LPEEK                            ; d0.l �� a1 �Ԓn�̒l�i_MACS �̃x�N�^�A�h���X�j���擾�i�X�[�p�[�o�C�U�̈�j
    movea.l d0,a1                               ; a1 �� _MACS �̃x�N�^�A�h���X���擾

    addq.l  #2,a1                               ; �x�N�^�A�h���X���� 2 Bytes ��ɐݒ�iMACSDRV �Ȃ� 'MACSIOCS' ������͂��j����
    IOCS    _B_LPEEK                            ;  ���̒l�� d0.l �Ɏ擾�i�X�[�p�[�o�C�U�̈�j
    cmp.l   #'MACS',d0                          ; 'MACS' �Ɣ�r����
    beq     @f                                  ;  �����Ȃ玟��

    pea.l   err_MACSDRV                         ; MACSDRV ���풓���Ă��܂���G���[
    bra     error                               ; �G���[�I��
@@:
    IOCS    _B_LPEEK                            ; d0.0 �Ɏ��̒l���擾�i�X�[�p�[�o�C�U�̈�j
    cmp.l   #'IOCS',d0                          ; 'IOCS' �Ɣ�r����
    beq     @f                                  ;  �����Ȃ� MACSDRV �͑g�ݍ��܂�Ă���̂Ŏ���

    pea.l   err_MACSDRV                         ; MACSDRV ���풓���Ă��܂���G���[
    bra     error                               ; �G���[�I��
@@:

check_MACSDRV_version:
    moveq.l #3,d1                               ; MACS�o�[�W�����`�F�b�N
    IOCS    _MACS                               ; �풓���Ă��� MACSDRV �̃o�[�W�������擾
    move.w  d0,d5                               ; d5 �� MACSDRV�o�[�W�������擾

    cmp.w   d4,d5                               ; MACSDATA�o�[�W�����Ɣ�r
    bge     @f                                  ; MACSDRV�o�[�W������MACS�f�[�^�o�[�W�����ȏ�Ȃ̂Ŏ���

    pea.l   err_version                         ; MACSDRV �̃o�[�W�������Â��ł��G���[
    bra     error                               ; �G���[����
@@:
    cmp.w   #$0116,d0                           ; �o�[�W����0.116 �Ɣ�r����
    ble     check_mainmem                       ; ��������΃n�C��������Ή��Ȃ̂Ń��C���������̃`�F�b�N��

;-----------------------------------------------------------------------------------------
; ���[�J���������̃`�F�b�N
;   d0.l �F �e���|�����i��� _MALLOC3 �̕Ԃ�l�j
;   d3.l �F �m�ۉ\�ȃ������T�C�Y
;   a1   �F �m�ۂ����������̐擪�A�h���X
;-----------------------------------------------------------------------------------------

check_localmem:
    pea     $FFFF_FFFF                          ; �m�ۂ��郁�����T�C�Y�i�킴�ƃG���[�ɂ��Ċm�ۉ\�ȍő僁�����T�C�Y���擾����j
    DOS      _MALLOC3                           ; 060turbo.sys �g��MALLOC�i_MALLOC3 �����݂���Ȃ�m�ۉ\�ȍő僁�����T�C�Y(���_�l256MB)�ɍŏ��bit�𗧂Ă��l���A���݂��Ȃ���� -1 �� d0 �ɕԂ�j
    addq.l  #4,sp                               ; SP ��߂��܂�
    move.l  d0,d3                               ; d3.l �ɕԂ�l��ۑ�
    addq.l  #1,d0                               ; d0.l ���C���N�������g�i_MALLOC3 �����݂��Ȃ��ꍇ�� -1 �Ȃ̂� 0 �ɂȂ�j
    beq     check_HIMEMSYS                      ; _MALLOC3 �����݂��Ȃ��̂� HIMEM.SYS �`�F�b�N

    bclr.l  #31,d3                              ; d3.l �̍ŏ��bit�������Ċm�ۉ\�ȍő僁�����T�C�Y(���_�l256MB)���擾
    cmp.l   #$00C0_0000,d3                      ; �m�ۉ\�ȃ������T�C�Y�� 12MB �Ɣ�r����
    blt     check_HIMEMSYS                      ;  ������������ HIMEM.SYS �`�F�b�N�i12MB�����̃��[�J�����������m�ۉ\�Ƃ����\�����������ł����m�ەs�Ƃ݂Ȃ��܂��j

allocate_localmem:                              ; 060turbo.sys + ���[�J��������(�n�C������)�m��
    move.l  d3,-(sp)                            ; �m�ۂ��郁�����T�C�Y
    DOS     _MALLOC3                            ; ���[�J�����������m�ہi�m�ۂł�����擪�A�h���X���A�ł��Ȃ������� -1 �� d0 �ɕԂ�j
    move.l  d0,(sp)+                            ; SP ��߂��� d0 �̔���
    bpl     @f                                  ; �m�ۂł����̂Ŏ���

    pea.l   err_localmem                        ; ���[�J�����������m�ۂł��܂���ł����G���[�i�\�����ʓ䌻�ہj
    bra     error                               ; �G���[����
@@:
    move.l  d0,a1                               ; a1 �ɐ擪�A�h���X���擾
    bset.b  #1,flg_memory                       ; ���[�J���������m�ۃt���O
    bra     load_macs                           ; MACS �t�@�C���̃��[�h

;-----------------------------------------------------------------------------------------
; �n�C������(HIMEM.SYS)�̃`�F�b�N�i060turbo.sys / TS16drv / TS16drvp ������g�ݍ��݉j
;   d0.l �F �e���|����
;   d1.l �F �e���|����
;   d2.l �F �m�ۂ��悤�Ƃ��郁�����T�C�Y�i�e���|�����j
;   d3.l �F �m�ۉ\�ȃ������T�C�Y
;   a1   �F �m�ۂ����������̐擪�A�h���X
;-----------------------------------------------------------------------------------------

check_HIMEMSYS:
    lea.l   $01f8*4.w,a1                        ; a1 �� IOCS $F8 (_HIMEM) �̃x�N�^�A�h���X���i�[����Ă���x�N�^�e�[�u���̃A�h���X���擾
    IOCS    _B_LPEEK                            ; d0.l �� a1 �Ԓn�̒l�i_HIMEM �̃x�N�^�A�h���X�j���擾�i�X�[�p�[�o�C�U�̈�j
    movea.l d0,a1                               ; a1 �� _HIMEM �̃x�N�^�A�h���X���擾

    subq.l  #6,a1                               ; �x�N�^�A�h���X���� 6 Bytes �O�ɐݒ�iHIMEM.SYS �Ȃ� 'HIMEM' + 1 byte ������͂��j����
    IOCS    _B_LPEEK                            ;  ���̒l�� d0.l �Ɏ擾�i�X�[�p�[�o�C�U�̈�j
    cmp.l   #'HIME',d0                          ; 'HIME' �Ɣ�r����
    bne     check_mainmem                       ; ����Ă����� HIMEM.SYS �͑g�ݍ��܂�Ă��Ȃ��̂Ń��C���������̃`�F�b�N��
    IOCS    _B_BPEEK                            ; d0.b �Ɏ��̒l���擾
    cmp.b   #'M',d0                             ; 'M' �Ɣ�r����
    bne     check_mainmem                       ; ����Ă����� HIMEM.SYS �͑g�ݍ��܂�Ă��Ȃ��̂Ń��C���������̃`�F�b�N��

allocate_highmem:
    moveq.l #3,d1                               ; �������c�ʂ�
    IOCS    _HIMEM                              ;  d1.l �Ɏ擾
    move.l  d1,d3                               ; d3.l �Ƀ������c�ʁ��m�ۉ\�ȍő僁�����T�C�Y���擾

    move.l  d1,d2                               ; �m�ۂ��悤�Ƃ��郁�����T�C�Y d2.l
    moveq.l #1,d1                               ; �������u���b�N��
    IOCS    _HIMEM                              ;   �m�ہi�m�ۂł�����擪�A�h���X�� a1 �ɁA�ł��Ȃ������� d0 �� -1 ���Ԃ�j
    tst.l   d0                                  ; d0 �̔���
    bpl     @f                                  ; �m�ۂł����̂Ŏ���

    pea.l   err_highmem                         ; �n�C���������m�ۂł��܂���ł����G���[�i�\�����ʓ䌻�ہj
    bra     error                               ; �G���[����
@@:
    bset.b  #2,flg_memory                       ; �n�C�������m�ۃt���O
    bra     load_macs                           ; MACS �t�@�C���̃��[�h

;-----------------------------------------------------------------------------------------
; ���C���������̃`�F�b�N
;   d0.l �F �e���|�����i��� _MALLOC �̕Ԃ�l�j
;   d3.l �F �m�ۉ\�ȃ������T�C�Y
;   a1   �F �m�ۂ����������̐擪�A�h���X
;-----------------------------------------------------------------------------------------

check_mainmem:
    pea     $FFFF_FFFF                          ; �m�ۂ��郁�����T�C�Y�i�킴�ƃG���[�ɂ��Ċm�ۉ\�ȃ������T�C�Y�ő�l���擾����j
    DOS     _MALLOC                             ; �������m�ہi�m�ۉ\�ȍő僁�����T�C�Y(���_�l12MB)�ɍŏ��byte�̃t���O�𗧂Ă��l�� d0 �ɕԂ�j
    addq.l  #4,sp                               ; SP ��߂��܂�
    andi.l  #$00FF_FFFF,d0                      ; d0.l �Ɋm�ۉ\�ȍő僁�����T�C�Y(���_�l12MB)���擾
    move.l  d0,d3                               ; d3.l �Ɋm�ۉ\�ȍő僁�����T�C�Y(���_�l12MB)���擾

allocate_mainmem:
    move.l  d3,-(sp)                            ; �m�ۂ��悤�Ƃ��郁�����T�C�Y
    DOS     _MALLOC                             ; ���C���������m�ہi�m�ۂł����� d0 �� �擪�A�h���X���Ԃ�A�ł��Ȃ������� d0 �ɕ��̒l���Ԃ�j
    move.l  d0,(sp)+                            ; SP ��߂��� d0 �̔���
    bpl     @f                                  ; ���̒l�ł͂Ȃ��̂Ŏ���

    pea.l   err_mainmem                         ; ���������m�ۂł��܂���ł����G���[�i�\�����ʓ䌻�ہj
    bra     error                               ; �G���[����
@@:
    movea.l d0,a1                               ; a1 �ɐ擪�A�h���X���擾
    bset.b  #0,flg_memory                       ; ���C���������m�ۃt���O

;-----------------------------------------------------------------------------------------
; MACS �t�@�C���̃��[�h
;   d0.l �F �e���|����
;   d3.l �� �m�ۉ\�ȃ������T�C�Y
;   d4.w �� MACSDATA�o�[�W����
;   d6.l �� �t�@�C���T�C�Y
;   d7.w �� �t�@�C���n���h��
;   a1   �� �m�ۂ����������̐擪�A�h���X
;-----------------------------------------------------------------------------------------

load_macs:
    cmp.l   d3,d6                               ; �m�ۉ\�ȃ������T�C�Y�ƃt�@�C���T�C�Y���r����
    blt     @f                                  ;  ���[�h�\�ł���Ύ���

    pea.l   err_sizeover                        ; ���������m�ۂł��܂���ł����G���[
    bra     error                               ; �G���[����
@@:
    clr.w   -(sp)                               ; ���[�h �t�@�C���擪����
    clr.l   -(sp)                               ; �I�t�Z�b�g 0
    move.w  d7,-(sp)                            ; �t�@�C���n���h��
    DOS     _SEEK                               ; �V�[�N���܂�
    addq.l  #8,sp                               ; SP ��߂��܂�
    tst.l   d0                                  ; d0 �̒l��
    bpl     @f                                  ;  ���̒l�łȂ���ΐ���Ȃ̂Ŏ���

    pea.l   err_fileseek                        ; �t�@�C�������Ă��܂��G���[
    bra     error                               ; �G���[����
@@:
    move.l  d6,-(sp)                            ; �t�@�C���T�C�Y
    pea.l   (a1)                                ; �m�ۂ����������̐擪�A�h���X
    move.w  d7,-(sp)                            ; �t�@�C���n���h��
    DOS     _READ                               ; MACS�f�[�^���������ɐς�
    lea     10(sp),sp                           ; SP ��߂��܂�

;-----------------------------------------------------------------------------------------
; MACS �f�[�^�̍Đ�
;   d1.l �F �e���|�����i_MACS�̈����j
;   d2.l �F �e���|�����i_MACS�̈����j
;   d4.l �F �e���|�����i_MACS�̈����j
;-----------------------------------------------------------------------------------------

    clr.l   d1                                  ;  0 : �A�j���[�V�����Đ�
    move.l  #-1,d2                              ; -1 : ������~����͂��܂���
    clr.l   d4                                  ;  0 : ������ʃt���O�͑S�I�t
    IOCS    _MACS                               ; MACS�Đ�

    bra     release_mem                         ; ���������

;-----------------------------------------------------------------------------------------
; �G���[����
;-----------------------------------------------------------------------------------------

error:
    DOS     _PRINT                              ; �\�������
    pea.l   mlib_crlf2                          ; ���s��
    DOS     _PRINT                              ;  �\�������
    addq.l  #8,sp                               ; SP ��߂��܂�

;-----------------------------------------------------------------------------------------
; �m�ۂ����������̉��
;   d1.l �F �e���|����
;   d2.l �F �e���|����
;   a1   :  �m�ۂ����������̐擪�A�h���X
;-----------------------------------------------------------------------------------------

release_mem:
    tst.b   flg_memory                          ; �������m�ۃt���O��
    beq     EXIT                                ;  �����Ă��Ȃ���΂����܂�
    btst.b  #2,flg_memory                       ; �������m�ۃt���O�� #2�i�n�C�������j�Ɣ�r
    bne     @f                                  ;  �����Ȃ�n�C�������̉����

    move.l  a1,-(sp)                            ; �m�ۂ����������̐擪�A�h���X
    DOS     _MFREE                              ; ���C��������/���[�J���������̉��
    addq.l  #4,sp                               ; SP ��߂��܂�

    bra     EXIT                                ; �����܂�
@@:
    move.l  a1,d2                               ; �m�ۂ����������̐擪�A�h���X
    moveq.l #2,d1                               ; �������u���b�N�̉��
    IOCS    _HIMEM                              ; �n�C�������̉��

;-----------------------------------------------------------------------------------------
; �����܂�
;-----------------------------------------------------------------------------------------

EXIT:
    DOS     _EXIT                               ; �����܂�

;=========================================================================================

;-----------------------------------------------------------------------------------------
; �^�C�g���\��
;-----------------------------------------------------------------------------------------

disp_Title:
    bsr     mlib_printtitle                     ; Title �\��
    rts

;=========================================================================================

    .data
    .even

;-----------------------------------------------------------------------------------------

mlib_title::
    .dc.b   'mcsp.x ',$00
mlib_version::
    .dc.b   $F3,'v',$F3,'e',$F3,'r',$F3,'s',$F3,'i',$F3,'o',$F3,'n',$F3,' '
    .dc.b   $F3,'1',$F3,'.',$F3,'0',$F3,'0',$F3,' ',$00
mlib_by::
    .dc.b   ' ',$F3,'b',$F3,'y ',$00
mlib_author::
    .dc.b   '�݂� (miyu rose)',$00

mes_help:
    .dc.b   ' mcsp [options] [MACSfile]',$0D,$0A
    .dc.b   '  [options]',$0D,$0A
    .dc.b   '   -d : macsdata information only (not play)',$0D,$0A
    .dc.b   $00

mes_dataversion:
    .dc.b   $F3,'D',$F3,'a',$F3,'t',$F3,'a',$F3,'V',$F3,'e',$F3,'r',$F3,'s',$F3,'i',$F3,'o',$F3,'n',$F3,':',$00

mes_filesize:
    .dc.b   ' ',$F3,'F',$F3,'i',$F3,'l',$F3,'e',$F3,'S',$F3,'i',$F3,'z',$F3,'e',$F3,':',$00

mes_unit_B:
    .dc.b   '[B]',$00

mes_unit_KB:
    .dc.b   '[KB]',$00

mes_unit_MB:
    .dc.b   '[MB]',$00

err_Human68k:
    .dc.b   'Human68k�̒v���I�ȃG���[�ɂ��ċN�����I�X�X�����܂�',$00

err_notmacs:
    .dc.b   'MACS�t�@�C������Ȃ��݂����ł�',$00

err_MACSDRV:
    .dc.b   'MACSDRV ���풓���Ă��Ȃ��悤�ł�',$00

err_version:
    .dc.b   'MACSDRV �̃o�[�W�������Â��悤�ł�',$00

err_localmem:
    .dc.b   '���[�J�����������m�ۂł��܂���ł���',$00

err_highmem:
    .dc.b   '�n�C���������m�ۂł��܂���ł���',$00

err_mainmem:
    .dc.b   '���C�����������m�ۂł��܂���ł���',$00

err_sizeover:
    .dc.b   '�\���ȋ󂫃�����������܂���ł���',$00

err_fileopen:
    .dc.b   '���w��̃t�@�C�����J���܂���ł���',$00

err_fileseek:
    .dc.b   '�t�@�C�������Ă���\��������܂�',$00

err_fileread:
    .dc.b   '�t�@�C����ǂݍ��݂ł��܂���ł���',$00

;-----------------------------------------------------------------------------------------

    .bss
    .even

;-----------------------------------------------------------------------------------------

flg_option:                                     ; bit76543210
    .ds.b    1                                  ;   %00000001 i �I�v�V����(���\���̂ݍĐ��i�V)

flg_memory:                                     ; bit76543210
    .ds.b    1                                  ;   %00000001 ���C���������m��
                                                ;   %00000010 ���[�J���������m��(060turbo.sys)
                                                ;   %00000100 �n�C�������m��(HIMEM.SYS/TS16DRVx)
buf_filepath:
    .ds.b    2
    .ds.b   64
    .ds.b   18
    .ds.b    4
buf_filepath_end:
    .ds.b    1

;-----------------------------------------------------------------------------------------

    .bss
    .even

;-----------------------------------------------------------------------------------------

buf_macsmagic:
    .ds.b    8
buf_dataversion:
    .ds.b    2
buf_macssize:
    .ds.l    1
buf_command:
    .ds.w    1
buf_comment:
    .ds.b   255
buf_comment_end
    .ds.b   1

;-----------------------------------------------------------------------------------------

    .stack
    .even

;-----------------------------------------------------------------------------------------

mystack:
    .ds.l   1024
mysp:
    .end    main

;=========================================================================================
