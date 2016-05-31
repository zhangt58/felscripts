      subroutine stepz(istepz,xkper0)
c     ==================================================================
c     advance one step in z
c     ------------------------------------------------------------------
c
      include 'genesis.def'
      include 'input.cmn'
      include 'magnet.cmn'
      include 'particle.cmn'
      include 'field.cmn'
c
      integer istepz, i
      real*8  xkper0
c
c
      call harmcoupling(awz(istepz))  ! get current coupling to radiation field
c
      call pushp(istepz,xkper0)       !push particles
c
      do i=1, nhloop
        call source(istepz,hloop(i))             !source term for radiation field
        call field(i)
      enddo                      !integrate wave equation
c
c     extensions to genesis 1.3
c 
      call incoherent(awz(istepz))    !subroutine supplied by pascal elleaume
                                      !include incoherent part of 
                                      !synchrotron radiation 
c
      return
      end     !stepz

c
