      subroutine output(istepz,islice,xkw0)
c     =============================================
c     calls all output function
c     ---------------------------------------------
c
      include 'genesis.def'
      include 'io.cmn'
      include 'diagnostic.cmn'
c
      integer istepz,islice
      real*8  xkw0
      character*11 file_id
c
      call diagno(istepz)
      call status(istepz,islice)
      if (islice.le.firstout) return
      call outfield(istepz,islice,xkw0)
      call outpart(istepz,islice)
      return
      end

      function openoutputfile(ierror,templatefilename)
c     ==================================================================
c     initial output of genesis.
c     ------------------------------------------------------------------
c
      include 'genesis.def'
      include 'mpi.cmn'
      include 'input.cmn'
      include 'io.cmn'
c
      character*(*) templatefilename
c
      integer ierror,i,isdefined,istr
 
      isdefined=0
      if (ierror.eq.erropenin) then 
        outputfile=templatefilename   !input file not file -> generate template
      else
        isdefined=1 
         if (index(outputfile,' ').eq.1) then    !no outputfile defined -> ask for it
            isdefined=0
            if (ilog.ne.0) then
              i=printerr(errrequest,'OUTPUTFILE')   !interaction required
              call last
            endif
            if (mpi_id.eq.0) then 
 1            write(6,100) 
              read(5,105) outputfile       !output file name not defined
              if (index(outputfile,' ').eq.1) then
                 i=printerr(errinvalname,outputfile)
                 goto 1
              endif   
            endif
            if (mpi_size.gt.1) then
               call MPI_BCAST(outputfile,30,MPI_CHARACTER,0,
     c                MPI_COMM_WORLD,mpi_err) !send outputfile name to all nodes  
            endif          
         endif                           !ask for output filename  
      endif
c
      nout=9
      openoutputfile=noerr

      if (mpi_id.gt.0) then
        return    ! only one template file or header file has to be written
      endif
c
      open(nout,file=outputfile,err=10,status='unknown') !open input file.
c
      if (ierror.eq.noerr)  then
        write(nout,110) genver,platf,inputfile
      else
        outputfile='' ! template is written -> prevents outputfile='template.in'
      endif
c
c     dump input parmeters
c
      write(nout,1000)
     +          aw0,xkx,xky,(wcoefz(i),i=1,3),xlamd,fbess0,delaw,
     +          iertyp,iwityp,awd,awx,awy,iseed,
     +          npart,gamma0,delgam,rxbeam,rybeam,alphax,alphay,
     +          emitx,emity,xbeam,ybeam,pxbeam,pybeam,
     +          conditx,condity,bunch,bunchphase,emod,emodphase,     
     +          xlamds,prad0,pradh0,zrayl,zwaist
      write(nout,1001)
     +          ncar,lbc,rmax0,dgrid,nscr,nscz,nptr,
     +          nwig,zsep,delz,nsec,iorb,zstop,magin,magout,
     +          quadf,quadd,fl,dl,drl,f1st,qfdx,qfdy,solen,sl,
     +          ildgam,ildpsi,ildx,ildy,ildpx,ildpy,itgaus,nbins,
     +          igamgaus,inverfc,     
     +          (lout(i),i=1,14+nhmax)
      write(nout,1002)
     +          iphsty,ishsty,ippart,ispart,ipradi,isradi,
     +          idump,iotail,nharm,iallharm,iharmsc,   
     +          curpeak,curlen,ntail,nslice,shotnoise,isntyp,iall,
     +          itdp,ipseed,iscan,nscan,svar,isravg,isrsig,
     +          cuttail,eloss,version,ndcut  
      write(nout,1003)
     +          idmpfld,idmppar,ilog,ffspec,convharm,ibfield,imagl,
     +          idril,alignradf,offsetradf,multconv,igamref,
     +          rmax0sc,iscrkup
      write(nout,1004)
     +          trama,
     +          itram11,itram12,itram13,itram14,itram15,itram16,
     +          itram21,itram22,itram23,itram24,itram25,itram26,
     +          itram31,itram32,itram33,itram34,itram35,itram36,
     +          itram41,itram42,itram43,itram44,itram45,itram46,
     +          itram51,itram52,itram53,itram54,itram55,itram56,
     +          itram61,itram62,itram63,itram64,itram65,itram66
c
      istr=strlen(beamfile)
      if (istr.gt.1) 
     c   write(nout,1010) 'beamfile =',beamfile(1:istr)
      istr=strlen(fieldfile)
      if (istr.gt.1) 
     c   write(nout,1010) 'fieldfile =',fieldfile(1:istr)
      istr=strlen(scan)
      if (istr.gt.1) 
     c   write(nout,1010) 'scan =',scan(1:istr)
      istr=strlen(outputfile)
      if (istr.gt.1) 
     c   write(nout,1010) 'outputfile =',outputfile(1:istr)
      istr=strlen(maginfile)
      if (istr.gt.1) 
     c   write(nout,1010) 'maginfile =',maginfile(1:istr)
      istr=strlen(magoutfile)
      if (istr.gt.1) 
     c   write(nout,1010) 'magoutfile =',magoutfile(1:istr)
      istr=strlen(partfile)
      if (istr.gt.1) 
     c   write(nout,1010) 'partfile =',partfile(1:istr)
      istr=strlen(distfile)
      if (istr.gt.1) 
     c   write(nout,1010) 'distfile =',distfile(1:istr)
      istr=strlen(radfile)
      if (istr.gt.1) 
     c   write(nout,1010) 'radfile =',radfile(1:istr)
      istr=strlen(filetype)
      if (istr.gt.1) 
     c   write(nout,1010) 'filetype =',filetype(1:istr)
      write(nout,1020) '$end'
c
      return 
c
 10   openoutputfile=printerr(erropen,outputfile)
      return
c
c     format statement 
c
 100  format('Please enter output file name ')
 105  format(a30)
 110  format(  '- - - - - - - - - - - - - - - - - - - - - - - -'
     c         '-----------------------------------------------',/,
     c         'Genesis 1.3 output start',/,
     c         '(Version ',f3.1,' ',a,')',/,/,
     c         'Input file name:  ',a30,/)
c
 1000 format(1x,'$newrun',/, 
     +       1x,'aw0   =',1pd14.6,/,
     +       1x,'xkx   =',1pd14.6,/,
     +       1x,'xky   =',1pd14.6,/,
     +       1x,'wcoefz=',3(1pd14.6,1x),/,
     +       1x,'xlamd =',1pd14.6,/,
     +       1x,'fbess0=',1pd14.6,/,
     +       1x,'delaw =',1pd14.6,/,
     +       1x,'iertyp=',i5,/,
     +       1x,'iwityp=',i5,/,
     +       1x,'awd   =',1pd14.6,/,
     +       1x,'awx   =',1pd14.6,/,
     +       1x,'awy   =',1pd14.6,/,
     +       1x,'iseed =',i5,/,
     +       1x,'npart =',i7,/,
     +       1x,'gamma0=',1pd14.6,/,
     +       1x,'delgam=',1pd14.6,/,
     +       1x,'rxbeam=',1pd14.6,/,
     +       1x,'rybeam=',1pd14.6,/,
     +       1x,'alphax=',1pd14.6,/,
     +       1x,'alphay=',1pd14.6,/,
     +       1x,'emitx =',1pd14.6,/,
     +       1x,'emity =',1pd14.6,/,
     +       1x,'xbeam =',1pd14.6,/,
     +       1x,'ybeam =',1pd14.6,/,
     +       1x,'pxbeam=',1pd14.6,/,
     +       1x,'pybeam=',1pd14.6,/,
     +       1x,'conditx =',1pd14.6,/,
     +       1x,'condity =',1pd14.6,/,
     +       1x,'bunch =',1pd14.6,/,
     +       1x,'bunchphase =',1pd14.6,/,
     +       1x,'emod =',1pd14.6,/,
     +       1x,'emodphase =',1pd14.6,/,     
     +       1x,'xlamds=',1pd14.6,/,
     +       1x,'prad0 =',1pd14.6,/,
     +       1x,'pradh0=',1pd14.6,/,
     +       1x,'zrayl =',1pd14.6,/,
     +       1x,'zwaist=',1pd14.6)
 1001 format(1x,'ncar  =',i5,/,
     +       1x,'lbc   =',i5,/,
     +       1x,'rmax0 =',1pd14.6,/,
     +       1x,'dgrid =',1pd14.6,/,
     +       1x,'nscr  =',i5,/,
     +       1x,'nscz  =',i5,/,
     +       1x,'nptr  =',i5,/,
     +       1x,'nwig  =',i5,/,
     +       1x,'zsep  =',1pd14.6,/,
     +       1x,'delz  =',1pd14.6,/,
     +       1x,'nsec  =',i5,/,
     +       1x,'iorb  =',i5,/,
     +       1x,'zstop =',1pd14.6,/,
     +       1x,'magin =',i5,/,
     +       1x,'magout=',i5,/,
     +       1x,'quadf =',1pd14.6,/,
     +       1x,'quadd =',1pd14.6,/,
     +       1x,'fl    =',1pd14.6,/,
     +       1x,'dl    =',1pd14.6,/,
     +       1x,'drl   =',1pd14.6,/,
     +       1x,'f1st  =',1pd14.6,/,
     +       1x,'qfdx  =',1pd14.6,/,
     +       1x,'qfdy  =',1pd14.6,/,
     +       1x,'solen =',1pd14.6,/,
     +       1x,'sl    =',1pd14.6,/,
     +       1x,'ildgam=',i5,/,
     +       1x,'ildpsi=',i5,/,
     +       1x,'ildx  =',i5,/,
     +       1x,'ildy  =',i5,/,
     +       1x,'ildpx =',i5,/,
     +       1x,'ildpy =',i5,/,
     +       1x,'itgaus=',i5,/,
     +       1x,'nbins =',i5,/,
     +       1x,'igamgaus =',i5,/,     
     +       1x,'inverfc =',i5,/,     
     +       1x,'lout  =',19(1x,i1))
 1002 format(1x,'iphsty=',i5,/,
     +       1x,'ishsty=',i5,/,
     +       1x,'ippart=',i5,/,
     +       1x,'ispart=',i5,/,
     +       1x,'ipradi=',i5,/,
     +       1x,'isradi=',i5,/,
     +       1x,'idump =',i5,/,
     +       1x,'iotail=',i5,/,
     +       1x,'nharm =',i5,/,
     +       1x,'iallharm =',i5,/,
     +       1x,'iharmsc =',i5,/,
     +       1x,'curpeak=',1pd14.6,/,
     +       1x,'curlen=',1pd14.6,/,
     +       1x,'ntail =',i5,/,
     +       1x,'nslice=',i5,/,
     +       1x,'shotnoise=',1pd14.6,/,
     +       1x,'isntyp=',i5,/,
     +       1x,'iall  =',i5,/,
     +       1x,'itdp  =',i5,/,
     +       1x,'ipseed=',i5,/,
     +       1x,'iscan =',i5,/,
     +       1x,'nscan =',i5,/,
     +       1x,'svar  =',1pd14.6,/,
     +       1x,'isravg=',i5,/,
     +       1x,'isrsig=',i5,/,
     +       1x,'cuttail=',1pd14.6,/,
     +       1x,'eloss =',1pd14.6,/,
     +       1x,'version=',1pd14.6,/,
     +       1x,'ndcut =',i5)
 1003 format(1x,'idmpfld=',i5,/,
     +       1x,'idmppar=',i5,/,
     +       1x,'ilog  =',i5,/,
     +       1x,'ffspec=',i5,/,
     +       1x,'convharm=',i5,/,
     +       1x,'ibfield=',1pd14.6,/,
     +       1x,'imagl=  ',1pd14.6,/,
     +       1x,'idril=  ',1pd14.6,/,
     +       1x,'alignradf=',i5,/,
     +       1x,'offsetradf=',i5,/,
     +       1x,'multconv=',i5,/,
     +       1x,'igamref=',1pd14.6,/,
     +       1x,'rmax0sc=',1pd14.6,/,
     +       1x,'iscrkup=',i5)
 1004 format(1x,'trama=',i5,/,
     +       1x,'itram11=',1pd14.6,/, 
     +       1x,'itram12=',1pd14.6,/,
     +       1x,'itram13=',1pd14.6,/,
     +       1x,'itram14=',1pd14.6,/,
     +       1x,'itram15=',1pd14.6,/,
     +       1x,'itram16=',1pd14.6,/,
     +       1x,'itram21=',1pd14.6,/,
     +       1x,'itram22=',1pd14.6,/,
     +       1x,'itram23=',1pd14.6,/,
     +       1x,'itram24=',1pd14.6,/,
     +       1x,'itram25=',1pd14.6,/,
     +       1x,'itram26=',1pd14.6,/,
     +       1x,'itram31=',1pd14.6,/,
     +       1x,'itram32=',1pd14.6,/,
     +       1x,'itram33=',1pd14.6,/,
     +       1x,'itram34=',1pd14.6,/,
     +       1x,'itram35=',1pd14.6,/,
     +       1x,'itram36=',1pd14.6,/,
     +       1x,'itram41=',1pd14.6,/,
     +       1x,'itram42=',1pd14.6,/,
     +       1x,'itram43=',1pd14.6,/,
     +       1x,'itram44=',1pd14.6,/,
     +       1x,'itram45=',1pd14.6,/,
     +       1x,'itram46=',1pd14.6,/,
     +       1x,'itram51=',1pd14.6,/,
     +       1x,'itram52=',1pd14.6,/,
     +       1x,'itram53=',1pd14.6,/,
     +       1x,'itram54=',1pd14.6,/,
     +       1x,'itram55=',1pd14.6,/,
     +       1x,'itram56=',1pd14.6,/,
     +       1x,'itram61=',1pd14.6,/,
     +       1x,'itram62=',1pd14.6,/,
     +       1x,'itram63=',1pd14.6,/,
     +       1x,'itram64=',1pd14.6,/,
     +       1x,'itram65=',1pd14.6,/,
     +       1x,'itram66=',1pd14.6)    
 1010 format(1x,a,1h',a,1h')
 1020 format(1x,a4)
      end !of outheader
c
c
      subroutine outglob
c     ==================================================================
c     output of global parameter (t-independend): 
c     z, wiggler field
c     ------------------------------------------------------------------
c
      include  'genesis.def'
      include  'input.cmn'
      include  'magnet.cmn'
      include  'io.cmn'
      include  'field.cmn'
      include  'sim.cmn'
      include  'time.cmn'
      include  'mpi.cmn'
c
      integer iz,itmp,i1,i2,i3,ntmp
      character*14 titel
      character*40 cwarn
      dimension titel(3)
c
      if (mpi_id.gt.0) return ! global variables only written by head node
c
c     ------------------------------------------------------------------ 
c     output of t independent values 
c
c     parameter for idl about file size etc.
c
      do iz=16,14+nhmax      ! starting at 16 lout indicates output for harmonics = 4 per harmonic.
         lout(iz)=4*lout(iz)
         if ((iallharm.eq.0).and.((iz-14).ne.nharm)) then
           lout(iz)=0
         endif
      enddo
c
      write(nout,10) 'flags for output parameter'
      write(nout,13) (lout(iz),iz=1,14+1*nhmax)
c
      itmp=0
      if (iphsty.gt.0) itmp=int(nstepz/iphsty)+1
      write(nout,11) itmp,' entries per record'
      i1=itmp
c
      itmp=nslice
      firstout=nslp*(1-iotail)*itdp    !=0 for scan, steady state and iotail=1 cases
      itmp=nslice-firstout
      itmp=int(itmp/ishsty)
      write(nout,11) itmp,' history records'
c
      write(nout,12) xlamds, ' wavelength'
      write(nout,12) dble(ishsty)*zsep*xlamds, 
     c               ' seperation of output slices'
c
      write(nout,11) ncar,' number of gridpoints'
      write(nout,12) dxy/xkper0,' meshsize'
      write(nout,14) npart,' number of particles'
c
      if (ippart.gt.0) then
         write(nout,11) nstepz/ippart+1,' particle: records in z'
         write(nout,11) itmp/ispart,' particle: records in t'
      else
         write(nout,11) 0,' particle: records in z'
         write(nout,11) 0,' particle: records in t'
      endif
      if (ipradi.gt.0) then
         write(nout,11) nstepz/ipradi+1,' field: records in z'
         write(nout,11) itmp/isradi,' field: records in t'
      else
         write(nout,11) 0,' field: records in z'
         write(nout,11) 0,' field: records in t'
      endif
c
c     calculation of output filesizes.
c     
      if ((itdp.ne.0).or.(iscan.gt.0)) then
         i2=0
         do i3=1,14+1*nhmax
             i2=i2+lout(i3)       !count number of output parameters
         enddo
         if (iscan.gt.0) itmp=nscan
         i2=i2*14                 !each entry has 14 character
         i2=i2*i1*itmp/1024/1024  !mutiply by #records and lines per record
         if (i2.gt.1) then
            write(cwarn,50) 'history',i2
            i2=printerr(errlargeout,cwarn)
         endif
      endif
      if (ippart.gt.0) then
         i2=(nstepz/ippart+1)*itmp/ispart !number of records and entries
         i2=i2*6*8*npart/1024/1024        !6 variables (real*8) per particle
         if (i2.gt.1) then
            write(cwarn,50) 'particle',i2
            i2=printerr(errlargeout,cwarn)
         endif
      endif
      if (ipradi.gt.0) then
         i2=(nstepz/ipradi+1)*itmp/isradi !number of records and entries
         i2=i2*16*ncar*ncar/1024/1024     !ncar**2 grid points (complex*16) 
         if (i2.gt.1) then
            write(cwarn,50) 'radiation',i2
            i2=printerr(errlargeout,cwarn)
         endif
      endif
c
c     output of global parameter (undulator field)
c
      if (iphsty.le.0) return
      titel(1)='    z[m]'
      titel(2)='    aw' 
      titel(3)='    qfld'
      write(nout,20) (titel(iz),iz=1,3)         !table heading
      
      do iz=0,nstepz,iphsty
         write(nout,21) iz*delz*xlamd,awz(iz)
     c                  ,qfld(iz)/586.
      end do

      if (mpi_size.gt.1) then !redirect output if mpi is running
         close(nout)
      endif
c
      return
c
 10   format(a)
 11   format(i5,a)
 12   format(e14.4,a)
 13   format(30i2)
 14   format(i7,a)
 20   format((3(a14))) 
 21   format((3(1pe14.4)))
 50   format('Size of ',a,' file [Mbytes]:',i4)      
c
      end
c

      subroutine outhist(islice)
c     ==================================================================
c     output calculation results
c        - history record
c     ------------------------------------------------------------------
c
      include  'genesis.def'
      include  'input.cmn'
      include  'diagnostic.cmn'
      include  'field.cmn'
      include  'io.cmn'
      include  'mpi.cmn'
c
      integer il,islice,ih,n,m,ill
      real*8 vout(15+4*(nhmax-1))
      character*12   file_id

c      
      if (iphsty.le.0) return                      !no output at all
      if (mod(islice,ishsty).ne.0) return          !output every ishstyth slice
      if (islice.le.firstout) return    		   !no output if in first slippage range
c
      if (mpi_size.gt.1) then  ! creata temporary files
        write(file_id,2) islice
        open(nout,file=outputfile(1:strlen(outputfile))//file_id,
     c           status='unknown')
      endif
 2    format('.slice',I6.6)
c
      call outhistheader(islice)
c 
c
      do ih=1,ihist
        n=0      
        do il=1,kout 
            if (iout(il).eq.1)  vout(il)=pgainhist(1,ih)
            if (iout(il).eq.2)  vout(il)=logp(ih)
            if (iout(il).eq.3)  vout(il)=pmidhist(1,ih)
            if (iout(il).eq.4)  vout(il)=phimid(1,ih)
            if (iout(il).eq.5)  vout(il)=whalf(ih)
            if (iout(il).eq.6)  vout(il)=diver(ih)
            if (iout(il).eq.7)  vout(il)=gamhist(ih)
            if (iout(il).eq.8)  vout(il)=pmodhist(1,ih)
            if (iout(il).eq.9)  vout(il)=xrms(ih)
            if (iout(il).eq.10) vout(il)=yrms(ih)
            if (iout(il).eq.11) vout(il)=error(ih)
            if (iout(il).eq.12) vout(il)=xpos(ih)
            if (iout(il).eq.13) vout(il)=ypos(ih)
            if (iout(il).eq.14) vout(il)=dgamhist(ih)
            if (iout(il).eq.15) vout(il)=ffield(1,ih)
c     output of harmonic content 16 -> 2nd harmonc, 17-> 3rd harm etc.
c     one entry in lout indicates to print four output parameters:
c     
            do ill=2,nhmax
               if (iout(il).eq.(14+ill)) then
	         vout(il+n)  =pmodhist(ill,ih) 
 	         vout(il+n+1)=pgainhist(ill,ih) 
	         vout(il+n+2)=bunphase(ill,ih)
	         vout(il+n+3)=pmidhist(ill,ih)
	         n=n+3
               endif
            enddo
        enddo
        write(nout,30) (vout(il),il=1,kout)
      enddo
c
c     format statements
c
 30   format((50(1pe14.4)))
c
      if (mpi_size.gt.1) close(nout)
c
      return
      end     !output
c
      subroutine outhistheader(islice)
c     ==================================================================
c     output calculation results
c        - history record
c     ------------------------------------------------------------------
c
      include  'genesis.def'
      include  'input.cmn'
      include  'field.cmn'
      include  'particle.cmn'
      include  'io.cmn'
      include  'sim.cmn'
c
      integer iz,islice,m,ih
      character*14 titel
      character*1  carh
      dimension titel(15+4*(nhmax-1))
c
      if (iphsty.le.0) return                      !no output at all
      if (mod(islice,ishsty).ne.0) return          !output ishstyth slice
c
c     -----------------------------------------------------------------
c     create output array for optional output
c
      titel(1) ='    power' 
      titel(2) ='    increment' 
      titel(3) ='    p_mid' 
      titel(4) ='    phi_mid' 
      titel(5) ='    r_size' 
      titel(6) ='    angle' 
      titel(7) ='    energy'
      titel(8) ='    bunching'
      titel(9) ='    xrms' 
      titel(10)='    yrms'
      titel(11)='    error'
      titel(12)='    <x>'
      titel(13)='    <y>'
      titel(14)='    e-spread'
      titel(15)='    far_field'
c     KG ----------------------------------------------------
      titel(16)='    2nd_bunching'
      titel(17)='    2nd_power'
      titel(18)='    2nd_phase'
      titel(19)='    2nd_p-mid'
      titel(20)='    3rd_bunching'
      titel(21)='    3rd_power'
      titel(22)='    3rd_phase'
      titel(23)='    3rd_p-mid'
      do ih=4,nhmax
        write(carh,50) ih
        titel(24+(ih-4)*4)='   '//carh//'th_bunching'
        titel(25+(ih-4)*4)='   '//carh//'th_power'
        titel(26+(ih-4)*4)='   '//carh//'th_phase'
        titel(27+(ih-4)*4)='   '//carh//'th_p-mid'
      enddo
c
c     --------------------------------------------------------------------
c     select output
c
      kout=0
      m=0
      do iz=1,15
         iout(iz)=0
         if (lout(iz).ne.0) then
            kout=kout+1 
            iout(kout)=iz
         endif
      enddo
c
      do iz=16, 14+nhmax     
        if (lout(iz).ne.0) then
	  iout(kout+1)=m+iz
	  iout(kout+2)=m+iz+1
	  iout(kout+3)=m+iz+2
	  iout(kout+4)=m+iz+3
	  kout=kout+4
	  endif
	  m=m+3
      enddo
c      
c
c     ---------------------------------------------------------------------
c     write header
c     
      write (nlog,5) islice
c
      if ((iscan.le.0).or.(iscan.gt.22)) then 
          write(nout,10) islice,xcuren         !time dependence
      else
          write(nout,11) islice,svalout        !scan parameter
      endif
      write(nout,20) (titel(iout(iz)),iz=1,kout)         !table heading
c
c     format statements
c     ------------------------------------------------------------------
 5    format('***  writing history record for slice ',i5)
 10   format(/'********** output: slice ',i5/
     f          5x,'      ================='/
     f       1x,1pe14.4,' current'//)
 11   format(/'********** output: slice ',i5/
     f          5x,'      ================='/
     f       1x,1pe14.4,' scan value'//)
 20   format((50(a14))) 
 50   format(I1.1)
c
      return
      end     !outputheader
c
c
c
      subroutine outpart(istepz,islice)
c     ==================================================================
c     output of global parameter (t-independend): 
c     z, wiggler field
c     ------------------------------------------------------------------
c
      include  'genesis.def'
      include  'io.cmn'
      include  'particle.cmn'
      include  'input.cmn'
      include  'work.cmn'
      include  'sim.cmn'
c
      integer iz,istepz,islice
c
c     ------------------------------------------------------------------ 
c     output of t independent values with first slice
c
      if ((ippart.le.0).or.(ispart.le.0)) return   !no output at all
      if (mod(istepz,ippart).ne.0) return          !output ippartth step
      if (mod(islice,ispart).ne.0) return          !output ispartth slice
c
      if (istepz.eq.0) call rpos(0,xpart,ypart)
      call getpsi(p1)
c
      if (npart.lt.npart0) then     ! check for particle loss
         do iz=npart+1,npart0       ! indicate lost particles with neg. energy
            gamma(iz)=-1.
         enddo
      endif
c
      write(npar,rec=irecpar) (gamma(iz),iz=1,npart0)
      write(npar,rec=irecpar+1) (p1(iz),iz=1,npart0)
c      write(npar,rec=irecpar+1) (theta(iz),iz=1,npart0)
      write(npar,rec=irecpar+2) (xpart(iz)/xkper0,iz=1,npart0)
      write(npar,rec=irecpar+3) (ypart(iz)/xkper0,iz=1,npart0)
      write(npar,rec=irecpar+4) (px(iz),iz=1,npart0)
      write(npar,rec=irecpar+5) (py(iz),iz=1,npart0)
      irecpar=irecpar+6
      return
      end
c
c
c
      subroutine status(istepz,islice)
c     ==================================================================
c     let user know % complete at every 10%.
c     ------------------------------------------------------------------
c
      include 'genesis.def'
      include 'input.cmn'
      include 'magnet.cmn'
      include 'io.cmn'
c
      integer istepz,islice
      real*8 xper,yper
c
      xper=100.d0*float(istepz)/float(nstepz)
      yper=100.d0*float(istepz-1)/float(nstepz)
      if (mod(xper,10.0d0).lt.mod(yper,10.0d0)) 
     +       write (nlog,20) islice,int(xper)
   20 format ('Slice ', i5,': Simulation ',i3,'% completed.')
c
      return
      end     !status
c
c
c
      subroutine outfield(istepz,islice,xkper0)
c     ==================================================================
c     dump fieldarray  
c     ------------------------------------------------------------------
c
      include 'genesis.def'
      include 'input.cmn'
      include 'io.cmn'
      include 'field.cmn'
c
      integer i,islice,istepz
      integer ioffset,ih,ifile
      real*8 scltmp,xkper0
c
      if ((ipradi.le.0).or.(isradi.le.0)) return   !no output at all
      if (mod(istepz,ipradi).ne.0) return          !output ipradith step
      if (mod(islice,isradi).ne.0) return          !output isradith slice
c
      scltmp=dxy*eev*xkper0/xks/dsqrt(vacimp)   !
      write(nfld,rec=irecfld) (scltmp* dble(crfield(i)),i=1,ncar*ncar)
      write(nfld,rec=irecfld+1) 
     +        (scltmp*dimag(crfield(i)),i=1,ncar*ncar)
      do ih=2,nhloop
          ioffset=(ih-1)*ncar*ncar
          ifile=nfldh(ih-1)
          write(ifile,rec=irecfld) 
     +	      (scltmp/hloop(ih)* dble(crfield(i)),
     +        i=1+ioffset,ncar*ncar+ioffset)
          write(ifile,rec=irecfld+1) 
     +        (scltmp/hloop(ih)*dimag(crfield(i)),
     +        i=1+ioffset,ncar*ncar+ioffset)
      enddo
c
      irecfld=irecfld+2

      return
      end
c
c
      subroutine outdump(islice)
c     ====================================================================
c     dump complete field array for future use
c     --------------------------------------------------------------------
c
      include 'genesis.def'
      include 'field.cmn'
      include 'timerec.cmn'
      include 'io.cmn'
      include 'work.cmn'
      include 'input.cmn'
      include 'time.cmn'
      include 'particle.cmn'
      include 'sim.cmn'
      include 'mpi.cmn'
c
      integer i,i0,j,islice,mpart,jj,iharm,ih,ioffset,ifile
      integer ndmp2tmp
      real*8  scltmp,phin,an,enum,ecorr
      character*12  file_id
      character*1   harm_id
c
      if (islice.le.firstout) return       ! suppress for IOTAIL=0
c
      write(file_id,2) islice
2     format('.slice',I6.6)

c
c     particle distribution
c
      if (idmppar.ne.0) then
        if (npart.lt.npart0) then
           do i=npart+1,npart0             ! check for particle losses
              gamma(i)=-1.                 ! indicate lost particles with neg. energy
           enddo
        endif
c                              
c       writing the record
c
          j=6*(islice-firstout-1)+1
c
          if (mpi_size.gt.1) then  ! creata temporary files
            ndmp2tmp=ndmp2
            ndmp2=ndmp2+30
            open(ndmp2,file=outputfile(1:strlen(outputfile))
     +                  //'.dpa'//file_id,
     +        status='unknown',access='direct',
     +        recl=npart*8,err=100)
            j=1           
          endif
c
          write(ndmp2,rec=j)   (gamma(i),i=1,npart0)
          write(ndmp2,rec=j+1) (theta(i),i=1,npart0)
          write(ndmp2,rec=j+2) (xpart(i)/xkper0,i=1,npart0)
          write(ndmp2,rec=j+3) (ypart(i)/xkper0,i=1,npart0)
          write(ndmp2,rec=j+4) (px(i),i=1,npart0)
          write(ndmp2,rec=j+5) (py(i),i=1,npart0)
c
          if (mpi_size.gt.1) then
            close(ndmp2)
            ndmp2=ndmp2tmp
          endif
      endif
c
c     field distribution
c
      if (idmpfld.eq.0) return     
c
c     problems arise if the dump is used for another run
c     any change in undulator period. the field has twice a scaling
c     with xkper0 - 1. eikonal equation + 2. normalization of dxy
c
      scltmp=dxy*eev*xkper0/xks/dsqrt(vacimp)   !
c
      j=islice-firstout
      if (mpi_size.gt.1) then  ! creata temporary files
        ndmp2tmp=ndump
        ndump=ndump+30
        open(ndump,file=outputfile(1:strlen(outputfile))
     +                  //'.dfl'//file_id,
     +        status='unknown',access='direct',
     +        recl=16*ncar*ncar,err=100)
        j=1           
      endif
c
      write(ndump,rec=j) (crfield(i)*scltmp,i=1,ncar*ncar)
c
      if (mpi_size.gt.1) then
         close(ndump)
         ndump=ndmp2tmp
      endif
c
c     harmonics
c      
 3    format(I1.1)
      do ih=2,nhloop
        j=islice-firstout
        ifile=ndumph(ih-1)
        ioffset=ncar*ncar*(ih-1)
        if (mpi_size.gt.1) then
          write(harm_id,3) hloop(ih)
          ifile=ifile+30
          open(ifile,file=outputfile(1:strlen(outputfile))
     +                  //'.dfl'//harm_id//file_id,
     +        status='unknown',access='direct',
     +        recl=16*ncar*ncar,err=100)
          j=1           
        endif
c 
        write(ifile,rec=j) (crfield(i)*scltmp/hloop(ih),
     +      i=1+ioffset,ncar*ncar+ioffset)
c
        if (mpi_size.gt.1) close(ifile)
c           
      enddo
c
      return
c
 100  i=printerr(erropen,'MPI Binary Temp Files')
      return
      end
c
      subroutine outdumpslippage
c     ==================================
c     dumps the escaped slippage field ahead of the bunch
c     ---------------------------------

      include 'genesis.def'
      include 'mpi.cmn'
      include 'io.cmn'
      include 'work.cmn'
      include 'input.cmn'
      include 'field.cmn'
      include 'time.cmn'
      include 'sim.cmn'
c
      integer i,j,i0,ioffset,ih,ifile
      real*8 scltmp
c  
      if (nslice.le.firstout) return       ! suppress for IOTAIL=0
      if (itdp.eq.0) return
      if (idmpfld.eq.0) return
      if (mpi_ID.gt.0) return
c
      scltmp=dxy*eev*xkper0/xks/dsqrt(vacimp)   !
c
      do j=nslp-1,1,-1                     ! dump field , escaping beam
        call pulltimerec(crwork3,ncar,j)
        i0=nslice+nslp-j-firstout
         write(ndump,rec=i0) (crwork3(i)*scltmp,i=1,ncar*ncar)
         do ih=2,nhloop
           ifile=ndumph(ih-1)
           ioffset=(ih-1)*ncar*ncar
           write(ifile,rec=i0) (crwork3(i)*scltmp/hloop(ih)
     +                         ,i=1+ioffset,ncar*ncar+ioffset)	
         enddo
      enddo
      return
      end
c
      subroutine closefile(nio)
c     =================================================================
c     closing file
c     ---------------------------------------------------------------
c
      logical isop
c
      if (nio.gt.6) then
        inquire(nio,opened=isop) 
        if (isop) close(nio)                   !close history file
      endif  
      return
      end ! of closefile
c
      function opentextfile(file,status,nio)
c     ==================================================================
c     open ascii file (sequential access)
c     ------------------------------------------------------------------ 
c    
c
      include 'genesis.def'
c
      character*(*) file,status
      integer nio

      opentextfile=nio
      open(nio,file=file,status=status,err=100)
      return
 100  opentextfile=printerr(erropen,file)
      return
      end ! of opentextfile
c
      function openbinfile(root,extension,nio,nsize)
c     ==================================================================
c     open binary file (direct access) as addition output file
c     ------------------------------------------------------------------ 
c    
c
      include 'genesis.def'
c
      character*30 root
      character*4  extension
      character*36 filename
      integer nio,nsize,j,jj

      openbinfile=nio
      j=index(root,' ')
      if (j.eq.0) j=31
      j=j-1
      jj=index(extension,' ')
      if (jj.eq.0) jj=5
      jj=jj-1
      filename=root(1:j)//'.'//extension(1:jj)
      open(nio,file=filename,status='unknown',access='direct',
     +    recl=nsize,err=100)
      return
 100  openbinfile=printerr(erropen,filename)
      return
      end ! of openbinfile
c
c
      subroutine openoutputbinmpi(islice)
c     ===========================================
c     open binary file for field, particle, dump field and dump particle
c     ------------------------------------------
c
      include 'genesis.def'
      include 'mpi.cmn'
      include 'io.cmn'
      include 'input.cmn'
      include 'field.cmn'
c
      character*12   file_id
      character*1    file_harm
      integer islice,iopenerr,j,i
c

      if (mpi_size.le.1) return      ! no mpi operation
c
      write(file_id,2) islice
 2    format('.slice',I6.6)
c
      j=index(outputfile,' ')
      if (j.eq.0) j=strlen(outputfile)+1
      j=j-1
c
      if (nfld.gt.0) then
        irecfld=1             ! reset record counter
        nfldmpi=nfld           ! save original file ID
        nfld=nfld+30
        open(nfld,file=outputfile(1:j)//'.fld'//file_id,
     +        status='unknown',access='direct',
     +        recl=ncar*ncar*16,err=100)
        do i=2,nhloop 
          nfldhmpi(i-1)=nfldh(i-1)
          nfldh(i-1)=nfldh(i-1)+30
          write(file_harm,5) hloop(i)
          open(nfldh(i-1),
     +        file=outputfile(1:j)//'.fld'//file_harm//file_id,
     +        status='unknown',access='direct',
     +        recl=ncar*ncar*16,err=100)          
        enddo
      endif
 5    format(I1.1)
c
      if (npar.gt.0) then
        irecpar=1
        nparmpi=npar
        npar=npar+30
        open(npar,file=outputfile(1:j)//'.par'//file_id,
     +        status='unknown',access='direct',
     +        recl=npart*8,err=100)
      endif
c
      return

 100  iopenerr=printerr(erropen,'MPI Binary Temp Files')

      return 
      end
c
      subroutine closeoutputbinmpi
c     ===========================================
c     close binary file for field, particle, dump field and dump particle
c     ------------------------------------------
c
      include 'genesis.def'
      include 'mpi.cmn'
      include 'io.cmn'
      include 'field.cmn'
      include 'input.cmn'
c
      integer i
c
      if (mpi_size.le.1) return      ! no mpi operation
c
      if (nfld.gt.0) then
       close(nfld)
       nfld=nfldmpi
       do i=2,nhloop
         close(nfldh(i-1))
         nfldh(i-1)=nfldhmpi(i-1)
       enddo
      endif
c
      if (npar.gt.0) then
       close(npar)
       npar=nparmpi
      endif
c
      return
      end
c

      subroutine first
c     ============================================
c     initial information for user
c     --------------------------------------------
c
      include 'genesis.def'
      include 'io.cmn'
c 
      write(nlog,100) genver,platf
      return

 100  format('-------------------------------',/,
     c       'Genesis 1.3 has begun execution',/,
     c       '(Version ',f3.1,' ',a,')',/)
      end


      subroutine last
c     ==================================================================
c     called at end of run.
c     closes all files, which must stay open during the run
c     ------------------------------------------------------------------
c
      include 'genesis.def'
      include 'io.cmn'
      include 'mpi.cmn'
c
      integer ih
c
      write (nlog,100)
      call closefile(nout)   !standard output
      call closefile(nfld)   !field output
      do ih=2,nhmax
         call closefile(nfldh(ih))  !harmonic field output      
         call closefile(ndumph(ih)) !dumped harmonic field     
      enddo
      call closefile(npar)   !particle output 
      call closefile(nfin)   !field input
      call closefile(npin)   !particle input
      call closefile(ndump)  !dumped field
      call closefile(ndmp2)  !dumped particle 
      call closefile(ndis)   !input distribution
      call closetimerec
c      
      write (nlog,200) !genesis has finished
c
      if (nlog.ne.6)  call closefile(nlog)   !log file
      call MPI_Finalize(mpi_err)
      stop
c
 100  format('***  closing files')
 200  format(/,'Genesis run has finished',/,
     c         '------------------------') 
      end     !last
c

      function printerr(ierr,text)
c     ========================================================
c     print error messages
c     --------------------------------------------------------
      
      include 'genesis.def'
      include 'io.cmn'

      integer ierr
      character*(*) text

      printerr=ierr
      if (ierr.ge.0) return
      goto (10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,
     c      25,26,27,28,29,30,31,32,33)
     c     ,iabs(ierr)
 10   write(nlog,100) text
      return
 11   write(nlog,101) text
      return
 12   write(nlog,102) text
      return
 13   write(nlog,103) text
      return
 14   write(nlog,104) text
      return
 15   write(nlog,105) text
      return
 16   write(nlog,106) text
      return
 17   write(nlog,107) text
      return
 18   write(nlog,108) text
      return
 19   write(nlog,109) text
      return
 20   write(nlog,110) text
      return
 21   write(nlog,111) text
      return
 22   write(nlog,112) text
      return
 23   write(nlog,113) text
      return
 24   write(nlog,114) text
      return
 25   write(nlog,115) text
      return
 26   write(nlog,116) text
      return
 27   write(nlog,117) text
      return
 28   write(nlog,118) text
      return
 29   write(nlog,119) text
      return
 30   write(nlog,120) text
      return
 31   write(nlog,121) text
      return
 32   write(nlog,122) text
      return
 33   write(nlog,123) text
      return
c
c     format statements
c
 100  format('***  File-error: ',a,/,
     c       '***  cannot be opened')
 101  format('***  File-error: ',a,/,
     c       '***  cannot be accessed')
 102  format('***  File-error: ',a,/,
     c       '***  cannot be opened',/,
     c       '***  creating template file: template.in')
 103  format('***  File-error: ',a,/,
     c       '***  error in namelise $newrun')
 104  format('***  Scan-warning: conflict with ITDP',/,
     c       '***  using scan-feature',a)
 105  format('***  Scan-warning: conflict with BEAMFILE',/,
     c       '***  ignoring BEAMFILE: ',a)
 106  format('***  Beamfile-warning: size exceeds NSMAX',/,
     c       '***  ',a)
 107  format('***  Input-error: ',a)
 108  format('***  Input-warning: ',a)
 109  format('***  Input-error: cannot convert to individiual input',/,
     c       '***  ',a)
 110  format('***  Numerical-error: boundary exceeded of',a,/,
     c       '***  ignoring exceeding elements')
 111  format('***  Round-warning: section not multiple of XLAMD',/,
     c       '***  MAGINFILE:',a)    
 112  format('***  Extrapolation-warning: exceeding time window of',/,
     c       '***  BEAMFILE by:',a)
 113  format('***  Scan-error: conflict with MAGINFILE:',a,/,
     c       '***  disabling scan-feature') 
 114  format('***  Scan-error: conflict with MAGOUTFILE:',a,/,
     c       '***  disabling scan-feature')
 115  format('***  Warning: particle loss of ',a,'%')
 116  format('***  Warning: external magnet definition too short for '
     c       ,a)
 117  format('***  Error: invalid filename:',a)
 118  format('***  File-error: cannot read from FIELDFILE:',a)
 119  format('***  Warning: ',a)
 120  format('***  Error: cannot run in background mode.',/,
     c       '***  information needed for ',a)
 121  format('***  Error: CRTIME cannot hold slippage field.',/,
     c       '***  see manual for allocating more memory',a)
 122  format('***  Error: unphysical parameter for loading',/,
     c       '***  ',a)
 123  format('***  ',a)
      end
