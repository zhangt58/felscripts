      subroutine initrun
c     ==================================================================
c     initialize the run by setting up
c     the precalculated matrices for the field solver and
c     claculating/normalizing some auxiliary variables
c
c     ------------------------------------------------------------------
c
      include 'genesis.def'
      include 'input.cmn'
      include 'particle.cmn'
      include 'sim.cmn'
      include 'field.cmn'
      include 'time.cmn'
      include 'magnet.cmn'
c
      real*8 xi
      integer ip,i
c
c     seeding of random number generator
c
      xi=ran1(iseed)          !init ran1
c
c      initiate loop for higher harmonics
c

c
      dedz=eloss*delz*xlamd/eev
      xcuren=curpeak
      npart0=npart                  !save total number or particle 
c
c     normalizations
c     ------------------------------------------------------------------
c
      xkw0= twopi/xlamd                       !wiggler wavenumber
      xkper0 = xkw0                           !transverse normalisation
c
c     magnetic field
c     ------------------------------------------------------------------   
c
      call magfield(xkper0,1)                   !magnetic field description
c
      if (inorun.ne.0) then
        ip=PRINTERR(ERRGENWARN,'Termination enforced by user')
        call last
      endif
c
c     slipping length
c
      nsep=int(zsep/delz)                      !steps between field slippage
      nslp=nstepz/nsep                         !total slippage steps
      if (mod(nstepz,nsep).ne.0) nslp=nslp+1   !if not added the effective undulator
                                               !would be shorter
c
c     contruct grid properties (grid spacing, precalculated matrices)
c
      dxy=xkw0*2.d0*dgrid/float(ncar-1)    
      xks=twopi/xlamds
c
c     time dependencies
c
      call loadslpfld(nslp)        !input field for first slice and seeding of ran-function
c
c     scanning
c
      call scaninit   !initialize scanning
c
c      
c
c     matrix initialization
      call getdiag(delz*xlamd,dxy/xkper0,xks)
c
c     clear space charge field for case that space charge is disabled
c
      do ip=1,npart   !clear space charge term
         ez(ip)=0.d0
      end do       ! ip

c
c
      return
      end
c
