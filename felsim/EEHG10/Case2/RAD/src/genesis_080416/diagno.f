      subroutine diagno(istepz)
c     ==================================================================
c     some diagnostics:
c     the radiation power must be calculated for each integration step
c     otherwise error will be wrong.
c     all calculation are stored in a history arrays which will be
c     written to a file ad the end of the run.
c     ------------------------------------------------------------------
c
      include  'genesis.def'
      include  'sim.cmn'
      include  'input.cmn'
      include  'field.cmn'
      include  'particle.cmn'
      include  'diagnostic.cmn'
      include  'work.cmn'
      include  'magnet.cmn'    ! unofficial
c
      integer i,ip,ix,iy,i0,i1,nn(2),istepz,nctmp,n
      integer ioff
      real*8 xavg,yavg,tpsin,tpcos,prad,ptot,gainavg,
     +       xxsum,yysum,cr2,crsum,wwcr,pradn 
      complex*16 ctmp 
c
      if (iphsty.le.0) return      !no output at all
      if (mod(istepz,iphsty).ne.0) return  ! no evaluation at this step
      if (istepz.eq.0) then 
          ihist=1                 ! first initialization of step counter
      else 
          ihist=ihist+1           ! advancing step counter for history counter
      endif
c
c     diagnostic: radiation field
c     -----------------------------------------------------------------
c     
c     radiation power
c
      do n=1, nhloop   ! looping over harmonics
        crsum=0.0d0
        ctmp=dcmplx(0.,0.)
        ioff=(n-1)*ncar*ncar
        do i=1+ioff,ncar*ncar+ioff
          wwcr=dble(crfield(i)*conjg(crfield(i))) !=sum of |aij|^2 
          crsum=crsum+wwcr
          ctmp=ctmp+crfield(i)
        end do
        pradn=crsum*(dxy*eev*xkper0/xks/hloop(n))**2/vacimp  != current radiation power
        if (n.eq.1) then    
          if ((pradoln(n).gt.0.d0).and.(pradn.gt.0.d0)) then
            logp(ihist)=dlog(pradn/pradoln(n))/(delz*xlamd) ! log derivative for fundamental harmonics
          else
            logp(ihist)=0.
          endif 
        endif
        gainavg=0.5d0*(pradn+pradoln(n))            !average with old power (leap frog!)
        pgainhist(hloop(n),ihist)=pradn
        pradoln(n)=pradn                            !store actual value as old value
c
c       on-axis far field intensity
c     
        ctmp=ctmp*eev*xkper0**2/xks/hloop(n)/sqrt(vacimp)   !scale it to dw/domega
        ffield(hloop(n),ihist)=dble(ctmp*conjg(ctmp)) ! far field on-axis (a.u.)   
c
c       on-axis near field intensity
c 
        i=ncar*(ncar-1)/2+(ncar+1)/2+(n-1)*ncar*ncar
      
        pmidhist(hloop(n),ihist)=dble(crfield(i)*conjg(crfield(i)))		!kg
     +       *(dxy*eev*xkper0/xks/hloop(n))**2/vacimp	
        phimid(hloop(n),ihist)=datan2(dimag(crfield(i)),
     +                  dble(crfield(i)))	
        if (ffspec.lt.0) then
	   phimid(hloop(n),ihist)=datan2(dimag(ctmp),dble(ctmp))
	   pmidhist(hloop(n),ihist)=ffield(hloop(n),ihist)                  		
	 
        endif
        if (ffspec.gt.0) then
	  pmidhist(hloop(n),ihist)=pgainhist(hloop(n),ihist)		!kg		
        endif
      enddo   !end of loop over harmonics
c         
c     radiation size  of fundamental
c
      if (pradoln(1).gt.0.d0) then
        crsum=0.
        xavg=0.0d0
        yavg=0.0d0
        cr2=0.0d0
        do iy=1,ncar
          do ix=1,ncar
            i=(iy-1)*ncar+ix
            wwcr=dble(crfield(i)*conjg(crfield(i)))
            crsum=crsum+wwcr
            xavg=xavg+wwcr*dble(ix)                      !sum up position
            yavg=yavg+wwcr*dble(iy)
            cr2=cr2+wwcr*dble(ix*ix+iy*iy)
          end do
        end do
        xavg=xavg/crsum                                !center of radiation
        yavg=yavg/crsum
        cr2=cr2/crsum-xavg*xavg-yavg*yavg
      else 
        cr2=0.d0
      endif
      whalf(ihist)=dsqrt(cr2)*dxy/xkper0     !rms radiation size

c
c     diagnostic: electron beam
c     ------------------------------------------------------------------
c
c     energy
c
      gamhist(ihist) =0.
      dgamhist(ihist)=0.
      do ip=1,npart
         gamhist(ihist) =gamhist(ihist)+(gamma(ip)-gamma0_in) 
         dgamhist(ihist)=dgamhist(ihist)+(gamma(ip)-gamma0_in)**2 
      enddo
      if (npart.gt.0) then
        gamhist(ihist)=gamhist(ihist)/dble(npart)
        dgamhist(ihist)=
     c      sqrt(dgamhist(ihist)/dble(npart)-gamhist(ihist)**2)
c
      endif
      ptot=pradoln(1)+eev * xcuren * gamhist(ihist)   !1st part of total energy      
      if (istepz.eq.0) pinit=ptot

c
c     bunching at nharm harmonics
c
      do i=1,nhloop
        tpsin=0.0d0                              
        tpcos=0.0d0
        do ip=1,npart
          tpsin=tpsin+dsin(theta(ip)*dble(i))          !add up phases
          tpcos=tpcos+dcos(theta(ip)*dble(i))
        end do   !ip
        if (npart.gt.0) then
          tpsin=tpsin/dble(npart)     
          tpcos=tpcos/dble(npart)
         endif
        pmodhist(i,ihist)=dsqrt(tpsin**2+tpcos**2) !bunching factor
        bunphase(i,ihist)=datan2(tpsin,tpcos)      !bunching phase
      enddo
      do i=nhloop+1,nhmax
        pmodhist(i,ihist)=0.
        bunphase(i,ihist)=0.
      enddo 

c
c     beam radius & energy spread
c
      xxsum=0.0d0    !reset counter
      yysum=0.0d0
      xpos(ihist)=0.0d0   
      ypos(ihist)=0.0d0
c     
      do i=1,npart
         xxsum=xxsum+xpart(i)**2     !sum of radii squared
         yysum=yysum+ypart(i)**2
         xpos(ihist)=xpos(ihist)+xpart(i)          !sum of radii 
         ypos(ihist)=ypos(ihist)+ypart(i)
      end do       ! i
      if (npart.gt.0) then
        xpos(ihist)=xpos(ihist)/dble(npart)/xkper0     !mean value
        ypos(ihist)=ypos(ihist)/dble(npart)/xkper0     
        xxsum=xxsum/dble(npart)/xkper0/xkper0    !mean square value
        yysum=yysum/dble(npart)/xkper0/xkper0    
      endif  
      xrms(ihist)=dsqrt(xxsum-xpos(ihist)**2)
      yrms(ihist)=dsqrt(yysum-ypos(ihist)**2)
c
c     energy conservation
c     ----------------------------------------------------------------
c
      error(ihist)=0.
      if (gainavg.ne.0.0) then
        error(ihist)=100.d0*(ptot/gainavg-pinit/gainavg)
      endif   
c
      if (lout(6).eq.0) return
c 
c     diffraction angle of radiation field
c     ---------------------------------------------------------------
c
      if (pradoln(1).eq.0) then   ! no radiation field
         diver(ihist)=0.
         return
      endif 
c
      nctmp=2**(int(log(float(ncar))/log(2.))+1)   !with nctmp> ncar
      do i1=1,nctmp*nctmp
         crwork3(i1)=(0.d0,0.d0)                   !clear working
      enddo
      i=(nctmp-ncar)/2                             !first index in bigger mesh
      do ix=1,ncar
         do iy=1,ncar
            i0=(ix-1)*ncar+iy
            i1=(ix-1+i)*nctmp+iy+i
            crwork3(i1)=crfield(i0)                !copy field around mid point 
         enddo
      enddo
      nn(1)=nctmp                                  !size of mesh
      nn(2)=nctmp
c
c     debug
c
c      crsum=0.0
c      do i=1,ncar*ncar
c         =crsum+dble(crwork3(i)*conjg(crwork3(i)))
c      enddo
c      write (*,*) 'field power before fft',crsum

      call fourn(crwork3,nn,2,1)                   !2d fft with complex variables 
c
c     debug
c
c      crsum=0.0
c      do i=1,ncar*ncar
c         crsum=crsum+dble(crwork3(i)*conjg(crwork3(i)))
c      enddo
c      write (*,*) 'field power before fft',crsum

c      pause
c
      do ix=1,nctmp/2                              !rearrange fft output
         do iy=1,nctmp/2
            i0=(ix-1)*nctmp+iy
            i1=(ix-1+nctmp/2)*nctmp+iy+nctmp/2
            ctmp=crwork3(i1) 
            crwork3(i1)=crwork3(i0) 
            crwork3(i0)=ctmp
            i0=(ix-1)*nctmp+iy+nctmp/2
            i1=(ix+nctmp/2-1)*nctmp+iy 
            ctmp=crwork3(i1) 
            crwork3(i1)=crwork3(i0) 
            crwork3(i0)=ctmp
         enddo
      enddo
c
      xavg=0.0d0
      yavg=0.0d0
      crsum=0.0d0
      do iy=1,nctmp
        do ix=1,nctmp
          i=(iy-1)*nctmp+ix
          wwcr=dble(crwork3(i)*conjg(crwork3(i)))
          xavg=xavg+wwcr*dble(ix)                      !sum up spatial frequency
          yavg=yavg+wwcr*dble(iy)
          crsum=crsum+wwcr
        end do
      end do
      if (crsum.gt.0.0) then
        xavg=xavg/crsum                                  !center of spatial frequency
        yavg=yavg/crsum
      else
        xavg=0.
        yavg=0.
      endif
c
      cr2=0.0d0
      do iy=1,nctmp
         do ix=1,nctmp
            i=(iy-1)*nctmp+ix
            wwcr=dble(crwork3(i)*conjg(crwork3(i)))
            cr2=cr2+wwcr*((dble(ix)-xavg)**2+(dble(iy)-yavg)**2)
         end do
      end do
c      
      if (crsum.le.0.0) then
         cr2=0.
         crsum=1.
      endif
c
      diver(ihist)=dsqrt(cr2/crsum)*xkper0*xlamds/dxy/dble(nctmp)  !rms divergence angle
c
      return
      end


