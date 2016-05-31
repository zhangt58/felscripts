      subroutine dotime(islice)
c     ===================================================================
c     set the beam parameter for the case of time-dependence
c     -------------------------------------------------------------------
c   
      include 'genesis.def'
      include 'input.cmn'
      include 'particle.cmn'
      include 'time.cmn'
      include 'sim.cmn'
c
      integer i,idx,islice
      real*8 invcur,zpos,w1,w2
      character*30 cdiff

      if (itdp.eq.0) return
c
      if (islice.eq.1) then
           npart0=npart    !save #particles
           w1=ran1(ipseed) !init ran1
      endif     
c
      npart=npart0   !compensate former particle losses
c
      if (ndata.le.1) then  !internal generation of time-dependence
         if (curlen.le.0.0) then
            invcur=0.
         else
            invcur=1./curlen
         endif
         zpos=dble(ntail+islice-1)*zsep*xlamds*invcur  !normalized t-position
         xcuren= curpeak*dexp(-0.5d0*zpos*zpos)          !beam current
         call dotimerad(islice)
         return
      endif
c
      zpos=dble((ntail+islice-1)*zsep)*xlamds  !position in m
c
      idx=luf(zpos,tpos,ndata)-1           !find position in array
      if (idx.le.0) idx=1
      if (idx.ge.ndata) idx=ndata-1
c
      if (zpos.lt.tpos(1)) then
        write(cdiff,*) (zpos-tpos(1)) 
        i=printerr(errextra,cdiff)            
      endif
      if (zpos.gt.tpos(ndata)) then
        write(cdiff,*) (zpos-tpos(ndata)) 
        i=printerr(errextra,cdiff)            
      endif
c
      w2=(zpos-tpos(idx))/(tpos(idx+1)-tpos(idx)) !weight of higher index
      w1=1.d0-w2                                  !weight of lower index       
      gamma0=w1*tgam0(idx)+w2*tgam0(idx+1)  !interpolation
      delgam=w1*tdgam(idx)+w2*tdgam(idx+1)  !temporary stored
      rxbeam=w1*txrms(idx)+w2*txrms(idx+1)  !into working arays
      rybeam=w1*tyrms(idx)+w2*tyrms(idx+1)
      xbeam=w1*txpos(idx)+w2*txpos(idx+1)
      ybeam=w1*typos(idx)+w2*typos(idx+1)
      emitx=w1*temitx(idx)+w2*temitx(idx+1)
      emity=w1*temity(idx)+w2*temity(idx+1)
      pxbeam=w1*tpxpos(idx)+w2*tpxpos(idx+1)
      pybeam=w1*tpypos(idx)+w2*tpypos(idx+1)
      alphax=w1*talphx(idx)+w2*talphx(idx+1)
      alphay=w1*talphy(idx)+w2*talphy(idx+1)
      xcuren=w1*tcurrent(idx)+w2*tcurrent(idx+1)  
      dedz=(w1*tloss(idx)+w2*tloss(idx+1))*delz*xlamd/eev 


      call dotimerad(islice)
      return
            
      end  ! of dotime

      subroutine dotimerad(islice)
c     ===================================================================
c     set the beam parameter for the case of time-dependence
c     -------------------------------------------------------------------
c   

      include 'genesis.def'
      include 'input.cmn'
      include 'field.cmn'
      include 'time.cmn'
      include 'sim.cmn'
c
      integer i,idx,islice
      real*8 invcur,zpos,w1,w2
      character*30 cdiff
      
      if (nraddata.le.1) return
      
         
      zpos=dble((ntail+islice-1)*zsep)*xlamds  !position in m
      idx=luf(zpos,tradpos,nraddata)-1           !find position in array
      if (idx.le.0) then
        write(cdiff,*) (zpos-tradpos(1)) 
        i=printerr(errextra,cdiff)            
        idx=1
      endif
      if (idx.ge.nraddata) then
        write(cdiff,*) (zpos-tradpos(ndata)) 
        i=printerr(errextra,cdiff)            
        idx=nraddata-1
      endif
      w2=(zpos-tradpos(idx))/(tradpos(idx+1)-tradpos(idx)) !weight of higher index
      w1=1.d0-w2                                  !weight of lower index       
      prad0=w1*tprad0(idx)+w2*tprad0(idx+1)  !interpolation
      zrayl=w1*tzrayl(idx)+w2*tzrayl(idx+1)  !temporary stored
      zwaist=w1*tzwaist(idx)+w2*tzwaist(idx+1)  !into working arays
      radphase=w1*tradphase(idx)+w2*tradphase(idx+1)

      if (prad0.lt.0) prad0=0

      return
      end   ! of doradtime
      
