      subroutine scaninit
c     ============================================================
c     initialize beam parameter for scanning
c     ------------------------------------------------------------
c
      include 'genesis.def'
      include 'input.cmn'
      include 'sim.cmn'
c
      if (iscan.le.0) return
c
      npart0=npart 
c
      if (iscan.gt.22) return !scan from beamfile      
c
      if (iscan.eq.1 ) sval=gamma0      !save original value
      if (iscan.eq.2 ) sval=delgam
      if (iscan.eq.3 ) sval=curpeak
      if (iscan.eq.4 ) sval=xlamds        !save original value
      if (iscan.eq.5 ) sval=aw0
      if (iscan.eq.6 ) sval=dble(iseed)
      if (iscan.eq.7 ) sval=pxbeam
      if (iscan.eq.8 ) sval=pybeam
      if (iscan.eq.9 ) sval=xbeam
      if (iscan.eq.10) sval=ybeam
      if (iscan.eq.11) sval=rxbeam
      if (iscan.eq.12) sval=rybeam     
      if (iscan.eq.13) sval=xlamd
      if (iscan.eq.14) sval=delaw
      if (iscan.eq.15) sval=alphax      
      if (iscan.eq.16) sval=alphay
      if (iscan.eq.17) sval=emitx
      if (iscan.eq.18) sval=emity
      if (iscan.eq.19) sval=prad0
      if (iscan.eq.20) sval=zrayl
      if (iscan.eq.21) sval=zwaist
      if (iscan.eq.22) sval=awd
c
      return
      end
c
c
      subroutine doscan(islice)
c     =========================================================================
c     modify parameter for scanning - several subroutines have to be rerun
c     -------------------------------------------------------------------------
c
      include 'genesis.def'
      include 'field.cmn'
      include 'input.cmn'
      include 'particle.cmn'
      include 'sim.cmn'
      include 'time.cmn'
c
      real*8 scale
      integer islice
c
      if (iscan.le.0) return
      npart=npart0 !compensate former particle losses
c
      if (iscan.gt.22) then    !use data from beamfile for each run of scan
        gamma0=tgam0(islice)  
        delgam=tdgam(islice)
        rxbeam=txrms(islice)
        rybeam=tyrms(islice)
        xbeam=txpos(islice)
        ybeam=typos(islice)
        emitx=temitx(islice)
        emity=temity(islice)
        pxbeam=tpxpos(islice)
        pybeam=tpypos(islice)
        alphax=talphx(islice)
        alphay=talphy(islice)
        xcuren=tcurrent(islice)
        dedz=tloss(islice)*delz*xlamd/eev 
        if (iscan.eq.24) then
           xlamds=0.5*xlamd*(1.d0+aw0*aw0)/gamma0/gamma0
           xks=twopi/xlamds
           call getdiag(delz*xlamd,dxy/xkper0,xks)
        endif
        if (iscan.eq.25) gamma0=gamma0_in
        return 
      endif
c
      scale=1.+svar*(2.*float(islice-1)/float(nslice-1)-1.)
      svalout=sval*scale   !save for output
      if (iscan.eq.6) svalout=sval+islice-1
c
c     beam parameters
c
      if (iscan.eq.1 ) gamma0=sval*scale
      if (iscan.eq.2 ) delgam=sval*scale
      if (iscan.eq.3 ) xcuren=sval*scale
      if (iscan.eq.7 ) pxbeam=sval*scale
      if (iscan.eq.8 ) pybeam=sval*scale
      if (iscan.eq.9 ) xbeam=sval*scale
      if (iscan.eq.10) ybeam=sval*scale
      if (iscan.eq.11) rxbeam=sval*scale
      if (iscan.eq.12) rybeam =sval*scale    
      if (iscan.eq.15) alphax=sval*scale      
      if (iscan.eq.16) alphay=sval*scale
      if (iscan.eq.17) emitx=sval*scale
      if (iscan.eq.18) emity=sval*scale
      if (iscan.le.3) return
      if ((iscan.ge. 7).and.(iscan.le.12)) return
      if ((iscan.ge.15).and.(iscan.le.18)) return
c
c     radiation parameters
c
      if (iscan.eq.4 ) then
          xlamds=sval*scale       
          xks=twopi/xlamds
          call getdiag(delz*xlamd,dxy/xkper0,xks)
      endif    
      if (iscan.eq.19) prad0=sval*scale
      if (iscan.eq.20) zrayl=sval*scale
      if (iscan.eq.21) zwaist=sval*scale
      if (iscan.eq.22) awd=sval*scale
      if ((iscan.eq.4).or.(iscan.ge.19)) return
c
c     magnets parameter
c
      if (iscan.eq.5 ) aw0=sval*scale
      if (iscan.eq.13) xlamd=sval*scale
      if (iscan.eq.14) delaw=sval*scale
      if (iscan.ne.6)  scale=ran1(-nint(sval)) !reinit ran1 function
      call magfield(xkw0,1)                      !recalculate magnetic field
      if (iscan.eq.13) call getdiag(delz*xlamd,dxy/xkper0,xks)
      return
      end
c
