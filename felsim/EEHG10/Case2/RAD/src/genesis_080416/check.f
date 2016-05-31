      subroutine chk_input
c     ============================================================
c     check for inconsistencies of correlated input parameter
c     such as magin and maginfile. guerantee compability for 
c     older versions of genesis 1.3
c     ------------------------------------------------------------
c
      include 'genesis.def'
      include 'input.cmn'
      include 'sim.cmn'
      include 'mpi.cmn'
      include 'field.cmn'
c
      integer i,ix
      real*8  rw0
c
c     set seeds for random number generator to negative value    
c
      iseed=-iabs(iseed)
      ipseed=-iabs(ipseed)-mpi_id
      quadf=abs(quadf)
      quadd=-abs(quadd)
c
c     save the input value for gamma0 for diagnostic output and advanced scan
c
      gamma0_in=gamma0
c
c     set flags to either 0 or 1 + adjust values 
c
      if (isravg.ne.0) isravg=1
      if (isrsig.ne.0) isrsig=1
      if (lbc.ne.0) lbc=1
      if (iorb.ne.0) iorb=1
      if (magin.ne.0) magin=1
      inorun=0							! do not stop after initialization 
      if (magout.lt.0) inorun=1 		! enforce termination after initialization
      if (magout.ne.0) magout=1
      if (idump.ne.0) idump=1
      if (idmppar.ne.0) idmppar=1
      if (idmpfld.ne.0) idmpfld=1
      if (iotail.ne.0) iotail=1
      if (ilog.ne.0) ilog=1
      if (iall.ne.0) iall=1
      if (itdp.ne.0) itdp=1
      if (wcoefz(2).gt.1) wcoefz(2)=1.d0
      if (iwityp.ne.0) iwityp=1
      if (delaw.lt.small) iertyp=0
      if (iertyp.eq.0) delaw=0.d0
      if (ffspec.ne.0) ffspec=ffspec/abs(ffspec)
      if (isntyp.ne.0) isntyp=1             
      if ((dgrid.le.small).and.(zrayl.gt.0.)) then  !grid size determined by beam size?
         rw0 = dsqrt((zrayl*xlamds/pi)*(1.0d0+(zwaist/zrayl)**2))
         dgrid = rmax0*(rw0+dsqrt(rxbeam**2+rybeam**2))/2.d0
      endif   
c
c     define harmonic content
c
      nhloop=1
      hloop(1)=1
      if (nharm.gt.1) then      ! changed to avoid nharm=0 settings
        if(iallharm.ne.0) then  ! denotes which harmonics shall be calculated
          nhloop=nharm
	  do i=2,nharm			    ! fill array with harmonic numbers
             hloop(i)=i
          end do			
        else
          nhloop=2              ! else only fundamental + one harmonic
	  hloop(2)=nharm
	endif
      else
        pradh0=0.
      endif
c
c     check for version specific changes
c
      if (idmppar.eq.0) idmppar=idump
c
      if (version.lt.1.0) then
         ffspec=0			!phase in near field
         isntyp=1			!shotnoise with Penman algorithm
         inorun=0
      else  
         if (idmpfld.eq.0) idmpfld=idump
      endif            
c
c     check case if time dependent code is selected
c
      if (itdp.eq.0) then
        nslice=1                             !one slice 
        zsep=delz                            !one bucket
        ntail=0                              !middle of the beam
        curlen=-1.d0                         !step profile in z
        shotnoise=0.d0                       !no phase fluctuation 
        iall=1                               !reference loading for scan
        ishsty=1                             !make sure for output
        isradi=1                             ! -- " --
        ispart=1                             ! -- " --
        iotail=0                             !cut tails
      endif
c
c     check for scan function 
c
      if (index(scan,' ').ne.1) iscan=chk_scan(scan,iscan)
c
      if (iscan.gt.0) then
        if (nscan.le.1) then
           i=printerr(errinwarn,'NSCAN too small for scan') 
           iscan=0
        else   
          if (((magin+magout).gt.0).and.((iscan.eq.5).or.(iscan.eq.6)
     c         .or.(iscan.eq.13).or.(iscan.eq.14))) then
            if (magin.ne.0) then
               i=printerr(errscanm1,maginfile) 
               iscan=0
            else
               i=printerr(errscanm2,magoutfile)
               iscan=0
            endif   
          else
            nslice=nscan
            iall=1
            zsep=delz
            curlen=-1.d0
            ntail=0
            iotail=0
            shotnoise=0.0
            if (itdp.ne.0) then
              i=printerr(errscant,' ')
              itdp=0
            endif
            if ((iscan.gt.22).and.(index(beamfile,' ').eq.0)) then
              i=printerr(errinput,'scan feature requires BEAMFILE')
              call last
            endif
          endif  
        endif  
      endif
c
c     check for magnet field input & output 
c
      if (index(maginfile,' ').ne.1) then
         magin=1
      else   
        if (magin.ne.0) then
          if (ilog.ne.0) then     
            i=printerr(errrequest,'MAGINFILE')   !interaction required
            call last
          endif
 1        write(6,100) 
          read(5,200) maginfile !get magnetic input file name
          if (index(maginfile,' ').eq.1) then
             i=printerr(errinvalname,maginfile)
             goto 1
          endif   
        endif
      endif 
      if (index(magoutfile,' ').ne.1) then
         magout=1
      else   
        if (magout.ne.0) then
           if (ilog.ne.0) then     
             i=printerr(errrequest,'MAGOUTFILE')   !interaction required
             call last
           endif
 2         write(6,110)
           read(5,200) magoutfile !get magnetic input file name
           if (index(magoutfile,' ').eq.1) then
              i=printerr(errinvalname,magoutfile)
              goto 2
           endif   
        endif
      endif 
c
c     check for output parameters
c
      if (ishsty.lt.1) ishsty=1
      if (ispart.lt.1) ispart=1
      if (isradi.lt.1) isradi=1
      ix=0
      do i=1,15+4*(nhmax-1)
         if (lout(i).ne.0) then
            ix=ix+1
            lout(i)=1
         endif   
      enddo
      if (ix.eq.0) iphsty=0
      return
c
c     format statements
c
 100  format('Please enter magnetic input file name')
 110  format('Please enter magnetic output file name')
 200  format(a30)
c 
      end !chk_input

      function chk_bnd()
c     ==================================================================
c     checks some boundaries of the input file.
c     ------------------------------------------------------------------
c
      include  'genesis.def'
      include  'input.cmn'
      include  'time.cmn'
      include  'io.cmn'
c
      integer itmp,ibas(7),i1,i2,i
c
c
c     check for the case that convharm is set if no partfile is defined 
c
      if (npin.le.0) convharm=1
c
      chk_bnd=noerr
      itmp=0     
c
c     case if nslice is smaller than 1  (auto-adjustment)  
c
      if (nslice.le.0) then
        if (curlen.lt.0) then      ! step profile
          ntail=0
          nslice=int(abs(curlen)/xlamds/zsep)
        else                       ! gaussian
          ntail=-int(3.d0*curlen/xlamds/zsep)
          nslice=int(6.d0*curlen/xlamds/zsep)
        endif
      endif 
c
c     adjustment for nslice if beamfile determines the scan
c
      if (iscan.gt.22) then
         if (ndata.le.0) then
            i=printerr(errinput,'BEAMFILE for scan not defined')
            call last
         endif
         nslice=ndata
         nscan=ndata
      endif

      if ((aw0.le.0.d0).and.(magin.eq.0)) then
         itmp=printerr(errinput,'No resonable wiggler field defined') !abort
      endif
      if (nwig.le.0) then
         itmp=printerr(errinput,'NWIG must be positive and non-zero')
      endif
      if (delz.le.0) then
         itmp=printerr(errinput,'DELZ must be positive and non-zero')
      endif
      if ((zsep.lt.1).and.(itdp.eq.1)) then
         itmp=printerr(errinput,'ZSEP must be al least 1')
      endif
      if (xlamd.le.0) then
         itmp=printerr(errinput,'XLAMD must be positive and non-zero')  !abort
      endif        
      if ((gamma0-4*abs(delgam)).lt.1) then
         itmp=printerr(errinput,'energy GAMMA0 too small')  !abort
      endif
      if(npart.gt.npmax) then
         i=printerr(errinwarn,'NPART > NPMAX - setting NPART=NPMAX')
      endif
      if (nbins.lt.4) then
        i=printerr(errinwarn,'NBINS too small - setting NBINS=4')
        nbins=4
      endif  
c      if(mod(npart,nbins*4).ne.0) then
c         itmp=printerr(errinput,'NPART not a multiple of 4*NBINS') !abort
c      endif
      do i1=nharm+1,nhmax
        if (lout(14+i1).ne.0) then
          i=printerr(errinwarn,'no harmonic output above NHARM')
        endif
      enddo 
      if (idmppar.gt.nharm) then
          i=printerr(errinwarn,'No dump possible (IDMPPAR > IHARM)')
          idmppar=0
      endif    
      if (xlamds.le.0) then
         itmp=printerr(errinput,'XLAMDS must be positive')  !abort
      endif        
      if (prad0.lt.0.d0) then
         itmp=printerr(errinput,'PRAD0 must not be negative')!abort
      endif
      if (pradh0.lt.0.d0) then
         itmp=printerr(errinput,'PRADH0 must not be negative')!abort
      endif
      ibas(1)=ildpsi
      ibas(2)=ildx
      ibas(3)=ildy
      ibas(4)=ildpx
      ibas(5)=ildpy
      ibas(6)=ildgam
      ibas(7)=ildgam+1
      do i1=1,7
       do i2=i1+1,7
        if (ibas(i1).eq.ibas(i2)) then !no abort
         i=printerr(errinwarn,'Identical bases in Hammersley sequences')
        endif
       enddo
      enddo   
      if ((abs(iertyp).ne.0).and.(abs(delz-0.5d0).gt.small)) then
         itmp=printerr(errinput,'DELZ must be 0.5 for field errors')
      endif
      if (iscan.gt.25) then
        i=printerr(errinwarn,'Invalid scan parameter - setting ISCAN=0')
        iscan=0
      endif
      if ((iscan.gt.0).and.((nscan.le.1).or.(abs(svar).lt.small))) then
         itmp=printerr(errinput,'Invalid scan range (NSCAN,SVAL)')
      endif
      if ((zsep/delz-1.*int(zsep/delz)).gt.small) then
         itmp=printerr(errinput,'ZSEP not a multiple of DELZ')
      endif 
      if (nslice.gt.nsmax) then
         itmp=printerr(errinput,'Too many slices (NSLICE>NSMAX)')
      endif
      if (nslice.le.0) then
         itmp=printerr(errinput,'NSLICE < 1')
      endif
      if (zrayl.le.0.) then
         itmp=printerr(errinput,'ZRAYL must be larger than 0')
      endif
      if(mod(ncar,2).eq.0) then
         itmp=printerr(errinput,'NCAR not an odd integer') 
      endif                
      if(ncar.gt.ncmax) then
         i=printerr(errinwarn,'NCAR too large - setting NCAR=NCMAX')
      endif                
      if (nptr.gt.nrgrid-1) then
         i=printerr(errinwarn,'NPTR too large - setting NPTR=NRGRID')
      endif
      if (nptr.lt.2) then
        i=printerr(errinwarn,'NPTR too small - disabling space charge')
        nscz=0
        nscr=0
      endif
      if (nscz.ge.(nbins/2+1)) then  !somehow empirical boundary
        i=printerr(errinwarn,'NSCZ too large - setting NSCZ=2')
        nscz=2
      endif        
      if (nharm.gt.(nbins/2+1)) then
        i=printerr(errinwarn,'Higher harmonics are inaccurate (NHARM)')
      endif
c
      chk_bnd=itmp
      return
      end     !chk_bnd
c
      function chk_scan(c0,iscn)
c     ============================================================
c     check for string in input scan
c     ------------------------------------------------------------
c
      character*30 c0
      integer i,j,iscn,chk_scan 
c
      chk_scan=iscn          !if not found use value if iscan
      call touppercase(c0)
      j=1
      do i=1,30               !conversion to uppercase 
         if (c0(i:i).gt.' ') j=i    !end of string?
      enddo

      if (c0(1:j).eq.'GAMMA0')  chk_scan=1
      if (c0(1:j).eq.'DELGAM')  chk_scan=2
      if (c0(1:j).eq.'CURPEAK') chk_scan=3
      if (c0(1:j).eq.'XLAMDS')  chk_scan=4
      if (c0(1:j).eq.'AW0')     chk_scan=5
      if (c0(1:j).eq.'ISEED')   chk_scan=6
      if (c0(1:j).eq.'PXBEAM')  chk_scan=7
      if (c0(1:j).eq.'PYBEAM')  chk_scan=8
      if (c0(1:j).eq.'RXBEAM')  chk_scan=11
      if (c0(1:j).eq.'RYBEAM')  chk_scan=12
      if (c0(1:j).eq.'XBEAM')   chk_scan=9
      if (c0(1:j).eq.'YBEAM')   chk_scan=10
      if (c0(1:j).eq.'XLAMD')   chk_scan=13
      if (c0(1:j).eq.'DELAW')   chk_scan=14
      if (c0(1:j).eq.'ALPHAX')  chk_scan=15
      if (c0(1:j).eq.'ALPHAY')  chk_scan=16
      if (c0(1:j).eq.'EMITX')   chk_scan=17
      if (c0(1:j).eq.'EMITY')   chk_scan=18
      if (c0(1:j).eq.'PRAD0')   chk_scan=19
      if (c0(1:j).eq.'ZRAYL')   chk_scan=20
      if (c0(1:j).eq.'ZWAIST')  chk_scan=21
      if (c0(1:j).eq.'AWD')     chk_scan=22
      if (c0(1:j).eq.'BEAMFILE')chk_scan=23
      if (c0(1:j).eq.'BEAMOPT') chk_scan=24
      if (c0(1:j).eq.'BEAMGAM') chk_scan=25

      
      return
      end
