      subroutine magfield(xkw0,isup)
c     ==================================================================
c     calculates the magnetic structure of the undulator
c     outputs: awz   - wiggler field on axis
c              awdz  - artificial k-parameter for matching of drifts 
c              awerr - kick of momentum due to field errors
c              qx    - focusing strength in x (>0 -> focusing)
c              qy    - focusing strength in y
c
c     working arrays: p1 - readin quadrupole field
c                     k2gg - quad offset in x         
c                     k3gg - quad offset in y         
c                     k2pp - correction in x         
c                     k3pp - correction in x         
c
c     ------------------------------------------------------------------
c
      include  'genesis.def'
      include  'input.cmn'
      include  'magnet.cmn'
      include  'mpi.cmn'
c
      integer nfl,ndl,ndrl,nfodol,n1st,nlat,i1,i2,i,iskip
      integer imz(11),nwigz,iserr,nsl,isup,itmp,nsecl
      real*8 norm,rn,rnx,rny,rold,xkw0,atmp
      real*8 corx(nzmax),cory(nzmax)
c
c=======================================================================
c set default version number for external magnetic file.
c
      magversion = 0.1        ! version of magnetic file
      unitlength = 0          ! unit length in magfile header
c
c=======================================================================
c
c     clear arrays
c
      do i=1,11
         imz(i)=0
      enddo 
      do i=1,nzmax
         awz(i)=0.
         awdz(i)=0.
         qfld(i)=0.
         solz(i)=0.
         awerx(i)=0.
         awery(i)=0.
         dqfx(i)=0.
         dqfy(i)=0.
         corx(i)=0.
         cory(i)=0.
         awdx(i)=0.
         awdy(i)=0.
      enddo   
c
c     read external file
c
      if (magin.ne.0) call magread(corx,cory,imz,isup)
c
c     estimate length of the undulator
c
      nstepz=0
      nlat=1
      nfodol=nint((fl+dl+2.*drl)/delz)    !steps of internal focusing lattice
      if (nfodol.le.0) nfodol=1
      nwigz=nint(nwig/delz)               !steps of internal undulator section 
      if (imz(4).gt.0) nfodol=imz(4)      !structure defined in input file 
      if (imz(1).gt.0) then
         nsec=1
         nwigz=imz(1)
         nstepz=imz(1)                    !aw0 in input file determines the total length
      endif
c
      if (nstepz.le.0) then               !length yet not defined
         if (nfodol.ge.nwigz) then
            nlat=1                        !# of lattice per section
         else
            nlat=nwigz/nfodol
            if (mod(nwigz,nfodol).gt.0) nlat=nlat+1
         endif   
         nstepz=nsec*nlat*nfodol
      endif   
      if (zstop.le.0) zstop=nstepz*delz*xlamd
cbart      if (zstop.le.(nstepz*delz*xlamd)) nstepz=zstop/xlamd/delz
      if (zstop.le.(nstepz*delz*xlamd)) nstepz=nint(zstop/xlamd/delz)
      if (nstepz.gt.nzmax) then
         i=printerr(errarrbnd,'undulator field')
         nstepz=nzmax
         zstop=nstepz*delz*xlamd
      endif   
c
      if(magin.ne.0) call chk_maglen(imz,nstepz)     ! check whether input file is long enough
c
c     check for inconsistent input
c 
      itmp=0 
      if (imz(4).le.0) then
        if ((fl/delz-1.*int(fl/delz)).gt.small) then
         itmp=printerr(errinput,'FL not a multiple of DELZ')
        endif   
        if ((dl/delz-1.*int(dl/delz)).gt.small) then
         itmp=printerr(errinput,'DL not a multiple of DELZ')
        endif   
        if ((drl/delz-1.*int(drl/delz)).gt.small) then
         itmp=printerr(errinput,'DRL not a multiple of DELZ')
        endif 
        if ((f1st/delz-1.*int(f1st/delz)).gt.small) then
         itmp=printerr(errinput,'F1ST not a multiple of DELZ')
        endif         
      endif
      if (imz(9).le.0) then
        if ((sl/delz-1.*int(sl/delz)).gt.small) then
         itmp=printerr(errinput,'SL not a multiple of DELZ')
        endif
      endif
      if (itmp.lt.0) call last
c
c     generatic magnetic field
c
      nfl=nint(fl/delz)            
      ndl=nint(dl/delz)
      ndrl=nint(drl/delz)
      n1st=nint(f1st/delz)+1      
      nsl=nint(sl/delz)      
      if (imz(9).gt.0) nsl=imz(9)
c
c     check for extreme long fodo cells 
c
      nsecl=nfodol*nlat
      if ((nfodol.gt.(2*nwigz)).and.(nfl.eq.ndl)) then ! if fulfilled nlat must be 1
         nsecl=nsecl/2   ! nsecl is even because fodo cell is symmetric 
         nstepz=nstepz/2 ! the length is calculated above but must corrected here.
      endif
c
      do i1=1,nsec
         rnx=awx*(2.d0*ran1(iseed)-1.d0)   !module offset in x
         rny=awy*(2.d0*ran1(iseed)-1.d0)   !module offset in y
         do i2=1,nsecl
            i=i2+(i1-1)*nsecl
            if (i.le.nstepz) then               !check for array boundary
c
c   if field not externally defined or if no taper defined
c
              if (imz(1).le.0) then   !main undulator field not defined yet
                 if (i2.le.nwigz) then
                    awz(i)=aw0
                    if (imz(10).le.0) awdx(i)=rnx ! offset in x
                    if (imz(11).le.0) awdy(i)=rny ! offset in y
                 endif
c
csven      undulator offset are only generated when the main undulator
csven      is NOT defined in the external file. This is in difference to
csven      quadrupole offset, where errors can be added later. Reason is that
csven      genesis cannot distinguish modules from taper or errors!
csven      hopefully the C++ version of genesis might solve this problem, because
csven      magnetic elements are used in linked lists, thus distingishable!
c
csven      Although accepted by Genesis, defining offsets in the external files
csven      while the main undulator is generated internally is quite illogical!!
c                    
              endif
c
              if (imz(2).le.0) then             !drif section 
                if (awz(i).lt.tiny) awdz(i)=awd
              endif
c
              if (n1st.gt.nfodol) n1st=1        !check for overflow of counter
              if (imz(4).le.0) then             !quadrupole field 
                 if (n1st.le.nfl) qfld(i)=quadf     
                 if ((n1st.gt.(nfl+ndrl)).and.
     c               (n1st.le.(nfl+ndrl+ndl))) qfld(i)=quadd
              endif 
              n1st=n1st+1
c
              if (imz(9).le.0) then             !solenoid field
                  if (i2.le.nsl) solz(i)=solen 
              endif                            
            endif  
         enddo   
      enddo
c
c     field taper: apply to existing lattice of awz(i) - either defined externally or aw0
c
      do i = 1, nstepz
         atmp=awz(i)
         awz(i)=faw0(i,wcoefz,delz,xlamd,atmp,nstepz)
      enddo
c
c
c     field errors: skip this part if iertyp=0 or if delaw=0 (no errors)
c
cbart      if((iertyp.eq.0).or.(delaw.lt.small)) then   ! no/ignore errors in external file
      if((iertyp.ne.0).and.(delaw.gt.small)) then   ! no/ignore errors in external file
         rn=0.
         iserr=0
         iskip=1
         if (iertyp.lt.0) iskip=2                  !correlated error
         do i=1,nstepz,iskip
               if (abs(iertyp).eq.1) then    
                  rn=delaw*(2.d0*ran1(iseed)-1.d0)*dsqrt(3.d0) !uniform error distribution
               else
                  rn=delaw*gasran(iseed)*dsqrt(2.d0)           !gaussian error distribution 
               endif
            awz(i)=awz(i)*(1.+rn)
         enddo   
         awz(0) = awz(1)
         if(iskip.eq.2) then   ! no/ignore errors in external file
           do i=1,nstepz-2,iskip
              if(awz(i)*awz(i+2).gt.small) then
                  awz(i+1) = (awz(i)+awz(i+2))/2.
                  else
                  if(awz(i+1).gt.small) awz(i+1) = awz(i)
              endif
           enddo   
         endif     !  correlated errors
      endif     ! iertyp = 0 or delaw = 0.
      awz(0) = awz(1)  !0
c
      norm=dsqrt(2.d0)          !normalization for the kick due to field errors
      if (iwityp.ne.0) norm=1. 
cbart      if (imz(2).le.0) then
        do i=1,nstepz
           if ((awz(i-1).gt.tiny).and.(awz(i).gt.tiny)) then
              awerx(i)=awerx(i)+(-1.)**i*(awz(i)-awz(i-1))*norm/pi
           endif
        enddo
cbart      endif  
c
      do i=1,nstepz
         awery(i)=awerx(i)*dble(iwityp) !is nonzero for helical undulators
      enddo   
c
c     scale quadrupole & solenoid field
      do i=1,nstepz
         qfld(i)=qfld(i)*586.0
         solz(i)=solz(i)*586.0
      enddo
c 
c     qfdx and qfdy can both be zero and the loop won't do anything.
c     the only check is, whether quadrupole errors are define in the
c     external input files.
c
      rold=0.
      rnx=0.
      rny=0.
      if ((imz(5).eq.0).and.(imz(6).eq.0)) then
        do i=1,nstepz
           if ((dabs(qfld(i)).gt.tiny).and.(dabs(rold).lt.tiny)) then !begin of new quadrupole
             if(qfdx.gt.small) rnx=qfdx*(2.*ran1(iseed)-1)   !offset
             if(qfdy.gt.small) rny=qfdy*(2.*ran1(iseed)-1)
           endif  
           rold=qfld(i)
           if(dabs(qfld(i)).gt.tiny) then
              dqfx(i)=rnx       !doen't matter whether 
              dqfy(i)=rny
           endif
        enddo   
      endif
c  
c     write file with field description.
c
      if ((magout.ne.0).and.(mpi_id.eq.0)) call magwrite(corx,cory,xkw0)
c
c     combine kicks off both planes
c
      do i=1,nstepz
csven         awerx(i)=awerx(i)+(dqfx(i)*qfld(i)+corx(i))/xkw0 !add kick of quad offset
csven         awery(i)=awery(i)+(dqfy(i)*qfld(i)+cory(i))/xkw0 !to kick of field errors
         awerx(i)=awerx(i)+corx(i)/xkw0 !add kick to field errors
         awery(i)=awery(i)+cory(i)/xkw0 !quadrupole offsets are now treated in track.f
         awdx(i)=awdx(i)*xkw0
         awdy(i)=awdy(i)*xkw0
      enddo
c
c     needed for output before 1st step
c
      qfld(0)=qfld(1)
      dqfx(0)=dqfx(1)
      dqfy(0)=dqfy(1)
      awdx(0)=awdx(1)
      awdy(0)=awdy(1)
c
      return
      end
c
c
      function faw0(i,wcoefz,delz,xlamd,aw0,nstepz)
c     ==================================================================
c     the wiggler amplitude profile along the undulator
c     the passed variable is the integration step istepz
c     this routine is called only once at the beginning
c
c     the tapering depends on wcoefz:
c             wcoefz(1): taper start location in z
c             wcoefz(2): gradient of field taper
c             wcoefz(3): the type of taper
c                             =0 -> no taper
c                             =1 -> linear taper
c                             =2 -> quadratic taper
c     ------------------------------------------------------------------
c
      implicit none
c
      real*8 z,taplen,pctap,fac,wcoefz(*),delz,xlamd,aw0,faw0
      integer i,nstepz
c
      z = dble(i)*delz*xlamd-wcoefz(1)   !position relative to taper start
      faw0=aw0
      if ((z.le.0.).or.(wcoefz(3).eq.0.)) return !before taper or no taper at all 
c
c    if external magnetic file includes taper, don't do anything
c
      pctap= wcoefz(2)        !taper gradient
      taplen=dble(nstepz)*delz*xlamd-wcoefz(1)  !taper length
c
c     taper models
c     ------------------------------------------------------------------
c
      if (wcoefz(3).lt.1.1d0)then
         fac=1.d0-pctap*z/taplen           !linear taper
      else
        if (wcoefz(3).lt.2.1d0) then
          fac=1.d0-pctap*z*z/taplen/taplen  !quadratic taper
        else
          fac=1
        endif
      endif
      faw0=fac*faw0  
c
      return
      end     !faw0
c
c
      function faw2(i,x,y)
c     ==================================================================
c     calculation of the square of the off-axis wiggler field at step i
c     the dependency on x and y is given by the wiggler type
c     ------------------------------------------------------------------
c
      include  'genesis.def'
      include  'magnet.cmn'
      include  'input.cmn'
c
      real*8 x,y,xt,yt
      integer i
c
      xt=x-awdx(i)   ! include offset
      yt=y-awdy(i)   ! in x and y
      faw2 = awz(i)*awz(i)*(1.d0+xkx*xt*xt+xky*yt*yt)
c
      return
      end     !faw2
c
c
      subroutine magwrite(corx,cory,xkw0)
c     ===================================================================
c     output of the used magentic field
c     -------------------------------------------------------------------
c
      include 'genesis.def'
      include 'magnet.cmn'
      include 'input.cmn'
c
      real*8 corx(*),cory(*),rold,rcur,xkw0
      integer i,ic,k,nmout,nr
      character*3  cid(11)
c
      if(magin.eq.0) magversion = 1.0 ! write in new format unless spec. otherwise
      cid(1)='AW '
      cid(2)='DP '    !not used in output -> can be recalculated from awx, cx and cy
      cid(3)='QF '
      cid(4)='QX '
      cid(5)='QY '
      cid(6)='AD '
      cid(7)='SL '
      cid(8)='CX '
      cid(9)='CY '
      cid(10)='AX'
      cid(11)='AY'
c
      nmout=opentextfile(magoutfile,'unknown',8)
      if (nmout.lt.0) return

c
c  write header of the file
c
      if(magversion.gt.0.12) then
         write(nmout,50) '# header is included'
         write(nmout,40) '? VERSION=',magversion,' including new format'
         write(nmout,45) '? UNITLENGTH=',xlamd*delz,':unit length'
     +                   //' in header'
      endif
c
      do k=1,11
         i=1
         ic=1
         nr=0
         rold=awz(i)
         if (k.eq.2) rold=0.d0
         if (k.eq.3) rold=qfld(i)/586.0
         if (k.eq.4) rold=dqfx(i)
         if (k.eq.5) rold=dqfy(i)
         if (k.eq.6) rold=awdz(i)
         if (k.eq.7) rold=solz(i)/586.0
         if (k.eq.8) rold=corx(i)
         if (k.eq.9) rold=cory(i)
         if (k.eq.10) rold=awdx(i)
         if (k.eq.11) rold=awdy(i)
 1       i=i+1
         ic=ic+1
         rcur=awz(i)
         if (k.eq.2) rcur= 0.d0
         if (k.eq.3) rcur=qfld(i)/586.
         if (k.eq.4) rcur=dqfx(i)
         if (k.eq.5) rcur=dqfy(i)
         if (k.eq.6) rcur=awdz(i)
         if (k.eq.7) rcur=solz(i)/586.
         if (k.eq.8) rcur=corx(i)
         if (k.eq.9) rcur=cory(i)
         if (k.eq.10) rcur=awdx(i)
         if (k.eq.11) rcur=awdy(i)
         if (i.gt.nstepz) then
cbart            if ((ic.gt.2).and.(k.ne.2)) then 
            if ((ic.ge.2).and.(k.ne.2)) then 
               if(magversion.gt.0.12) then
                  write(nmout,60) cid(k),rold,ic-1,nr
                  nr=0
                  else
                  write(nmout,30) cid(k),rold,delz*xlamd,ic-1
               endif
            endif
            goto 2
         endif
         if ((dabs(rcur-rold).gt.tiny).and.(k.ne.2)) then
            if(magversion.gt.0.12) then
               if(abs(rold).lt.tiny) then
                  nr=ic-1
                  else
                  write(nmout,60) cid(k),rold,ic-1,nr
                  nr=0
               endif
               else
               write(nmout,30) cid(k),rold,delz*xlamd,ic-1
            endif
            rold=rcur
            ic=1
         endif
         goto 1
 2      continue   
      enddo   
c
      close(nmout)
      return
c
c     format statements
c
  30  format(a3,1x,1pe14.4,1x,1pe14.4,1x,i4) 
  40  format(a,1x,1f4.2,1x,a) 
  45  format(a,1x,1f7.5,1x,a) 
  50  format(a) 
  60  format(a3,1x,1pe14.4,1x,i4,1x,i4) 
      end  
  
c
c
c
      subroutine magread(corx,cory,imz,isup)
c     ========================================================================
c     input of the magnetic field.
c     only those parameters are replace which are included in the list
c     format : indicator - strength - length - number
c     inticator: aw - wiggler field
c                ad - phase matching between drift section 
c                dp - kick due to field errors 
c                qf - quadrupole field
c                qx - quadrupole offset in x
c                qy - quadrupole offset in y
c                cx - corrector strength in x
c                cy - corrector strength in y
c                sl - solenoid field
c				 ax - undulator offset in x
c				 ay - undulator offset in y
c
c     note: dp,co qx are combined into awerx. output is only dp

c     --------------------------------------------------------------------------
c
      include 'genesis.def'
      include 'magnet.cmn'
      include 'input.cmn'
c
      character*30 cmagtype(12),cin
      character*255 line
      real*8 r1,r2,corx(*),cory(*)
      real*8 r3,values(4),val
      integer i,nr,imz(11),imzb(11),idum,isup
      integer loop,loopcnt,j,k,ntemp,nmin
      integer nloop,ninfo,nr2
      integer int_version,ncol,ierr,nlen,idx
c
      if(isup.ne.0) then
      if(wcoefz(2).ne.0)
     +      ierr=printerr(errinwarn,'Taper defined in namelist')
      if((iertyp.ne.0).and.(abs(delaw).gt.small))
     +      ierr=printerr(errinwarn,'Wiggler errors'//
     +                   ' defined in namelist')
      if(abs(qfdx).gt.small)
     +      ierr=printerr(errinwarn,'Random quad offset errors in x'//
     +                   ' defined in namelist')
      if(abs(qfdy).gt.small)
     +      ierr=printerr(errinwarn,'Random quad offset errors in y'//
     +                   ' defined in namelist')
      if(abs(awx).gt.small)
     +  ierr=printerr(errinwarn,'Random undulator offset errors in x'//
     +                   ' defined in namelist')
      if(abs(awy).gt.small)
     +  ierr=printerr(errinwarn,'Random undulator offset errors in y'//
     +                   ' defined in namelist')
      endif
c
      cmagtype(1)='undulator field'
      cmagtype(2)='drift section'
      cmagtype(3)='field errors'      ! not used anymore
      cmagtype(4)='quadrupole field'
      cmagtype(5)='quadrupole offset in x'
      cmagtype(6)='quadrupole offset in y'
      cmagtype(7)='orbit correction in x'
      cmagtype(8)='orbit correction in y'
      cmagtype(9)='solenoid field'
      cmagtype(10)='undulator offset in x'
      cmagtype(11)='undulator offset in y'

      unitlength = 0.0  ! unit length has to be checked for new version
c
      nlen=len(line)  ! line size can be easily changed
      loop=0
      loopcnt=0
      int_version=2   ! check if version set to 0.1
      ncol=3          ! default older version to read 3 numbers after the identifier
c
c     open file 
c
      nmin=opentextfile(maginfile,'old',8)
      if (nmin.lt.0) return
c
 1    read(nmin,1000,end=2,err=100) line    ! read line
c   
      call touppercase(line)                !convert to upper case
      call getfirstchar(line,idx)           !get index of first non-space char. 
c
      if (idx.eq.0) goto 1                  !empty line
      if (line(idx:idx).eq.'#') goto 1      !comment line
      if (line(idx:idx).eq.'?') then        !information line
         call getmagfileinfo(line(idx+1:nlen))
         if(magversion.lt.0.11) then
             ncol=3
             int_version=1
         else
             ncol=3                         !read 4 number at version >= 1.0
         endif
         goto 1
      endif
      if (line(idx:idx).eq.'!') then        ! start/end loop structure
         line=line(idx+1:nlen)
         call getfirstchar(line,idx)
         if (idx.eq.0) then   
            i=printerr(errinwarn,'Empty line behind "!": ignored')
            goto 1
         endif
c
c check for start of loop: set loop counter
c
         nloop=index(line,'LOOP')
         if (nloop.eq.0) then
            ierr=printerr(errinwarn,'Undefined command in maginfile')
            goto 1
         endif
         if (nloop.eq.idx) then
            if(loop.eq.1) then ! start next loop before ending previous 
               nloop=printerr(errinwarn, 'Illegal ending of loop') ! forced stop
               close(nmin)
               call last
            endif     
            ierr=extractnumber(line(idx+4:nlen),val)
            if (ierr.lt.0) then
               i=printerr(errinwarn,'Undefined loop argument')
               goto 1
            else
               loopcnt=int(val)
            endif
            if (loopcnt.gt.1) then
               loop=1
               do k=1,11
                  imzb(k)=imz(k)
               enddo 
            endif  
            goto 1
         endif
c
c check for loop ending: reset loopcounter and copy loop
c
         nloop=index(line,'ENDLOOP')
         if((nloop.eq.idx).and.(loop.eq.1)) then        ! a loop is ended
            do j=2,loopcnt   ! copy filed loopcnt-1 times
              do k=1,11 
                 ntemp=imz(k)-imzb(k)
                 if ((imz(1)+ntemp).gt.nzmax) then
                    idum=printerr(errarrbnd,cmagtype(k))
                 else
                   do i=1,ntemp
                     if (k.eq.1) awz(imz(1)+i)=awz(imzb(1)+i)
                     if (k.eq.2) awdz(imz(2)+i)=awdz(imzb(2)+i)
                     if (k.eq.4) qfld(imz(4)+i)=qfld(imzb(4)+i)
                     if (k.eq.5) dqfx(imz(5)+i)=dqfx(imzb(5)+i)
                     if (k.eq.6) dqfy(imz(6)+i)=dqfy(imzb(6)+i)
                     if (k.eq.7) corx(imz(7)+i)=corx(imzb(7)+i)
                     if (k.eq.8) cory(imz(8)+i)=cory(imzb(8)+i)
                     if (k.eq.9) solz(imz(9)+i)=solz(imzb(9)+i)
                     if (k.eq.10) awdx(imz(10)+i)=awdx(imzb(10)+i)
                     if (k.eq.11) awdy(imz(11)+i)=awdy(imzb(11)+i)
                   enddo
                   imz(k) = imz(k)+ntemp
                   imzb(k)=imzb(k)+ntemp
                 endif
              enddo
            end do
            loop=0     !finish the round of copying
            loopcnt=0
            goto 1
         endif
      endif
c
c     process input line
c
      cin=line(idx:idx+1)   !get identifier
      k=-1
      if (cin(1:2).eq.'AW') k=1 !main wiggler field
      if (cin(1:2).eq.'AD') k=2 !art. wiggler field between section
      if (cin(1:2).eq.'QF') k=4 !quadrupole field strength
cbart      if (cin(1:2).eq.'QD') k=5 !quadrupole offset in x
      if (cin(1:2).eq.'QX') k=5 !quadrupole offset in x
      if (cin(1:2).eq.'QY') k=6 !quadrupole offset in y
      if (cin(1:2).eq.'CX') k=7 !correcter strength in x
      if (cin(1:2).eq.'CY') k=8 !corrector strength in y
      if (cin(1:2).eq.'SL') k=9 !solenoid strength
      if (cin(1:2).eq.'AX') k=10 !undulator offset in x
      if (cin(1:2).eq.'AY') k=11 !undulator offset in y
      if (k.lt.0) then
         ierr=printerr(errconv,cin(1:2))
         goto 1
      endif
c      
      line=line(idx+2:nlen)
      call getfirstchar(line,idx) !eliminate spaces in the beginning
      if (idx.gt.0) line=line(idx:nlen) 
      ierr=extractval(line,values,ncol)
      if (ierr.lt.0) then
         ierr=printerr(errconv,line)
         goto 1
      endif
      r1=values(1)              !strength/offset
c
c     filling the arrays
c
      if (magversion.ge.0.12) then
         nr=nint(values(2))         !length in unit length
         nr2=nint(values(3)) !separation to prev. element       
         if((nr.lt.0).or.(nr2.lt.0)) then
            idum=printerr(errinput,'Negative element'
     +            //' length/distance in maginfile')
            call last
         endif
         r2=unitlength              !unit length
         r3=r2*nr2

         nr2 = nint(r3/delz/xlamd)
         if(abs(nr2-r3/delz/xlamd).gt.small) then
            i=printerr(errmagrnd,line) ! different error needed ?????????
         endif 
         if ((imz(k)+nr2).gt.nzmax) then
            idum=printerr(errarrbnd,cmagtype(k))
         else
            imz(k)=imz(k)+nr2
         endif 
         else
         r2=values(2)              !unit length
         nr=nint(values(3))         !length in unit length
         if((nr.lt.0).or.(r2.lt.-small)) then
            idum=printerr(errinput,'negative element'
     +            //' length/distance in maginfile')
            call last
         endif
      endif
c
      r2=r2*nr                !full length of this section
      nr=nint(r2/delz/xlamd)  !# int. steps for this section
      if(abs(nr-r2/delz/xlamd).gt.small) then
        i=printerr(errmagrnd,line) 
      endif 
      if ((imz(k)+nr).gt.nzmax) then
         idum=printerr(errarrbnd,cmagtype(k))
      else
         do i=1,nr
            if (k.eq.1) awz(imz(1)+i)=r1
            if (k.eq.2) awdz(imz(2)+i)=r1
            if (k.eq.4) qfld(imz(4)+i)=r1
            if (k.eq.5) dqfx(imz(5)+i)=r1
            if (k.eq.6) dqfy(imz(6)+i)=r1
            if (k.eq.7) corx(imz(7)+i)=r1
            if (k.eq.8) cory(imz(8)+i)=r1
            if (k.eq.9) solz(imz(9)+i)=r1
            if (k.eq.10) awdx(imz(10)+i)=r1
            if (k.eq.11) awdy(imz(11)+i)=r1
         enddo
         imz(k)=imz(k)+nr
      endif
      goto 1      ! read new line
c
c     final processing + closing files
c
 2    if(int_version.eq.2) magversion = 1.0
      if(loop.eq.1) ninfo=
     c       printerr(errinwarn, '"LOOP" not terminated: no loop') 
      call closefile(nmin)
c
      return 
c
c     error
c
 100  idum=printerr(errread,maginfile)
      goto 1
c
c     format statements
c
 1000 format(a)
c
      end

c
      subroutine chk_maglen(imz,nstepz)
c     ===================================================================
c     checks whether the user supplied file for the description of the
c     magnetic fields is incomplete
c     -------------------------------------------------------------------
c
      include 'genesis.def'
c
      character*30   cmagtype(11)
      integer i,j,imz(11),nstepz
c
      cmagtype(1)=' undulator field'
      cmagtype(2)=' drift section'
      cmagtype(4)=' quadrupole field'
      cmagtype(5)=' quadrupole offset in x'
      cmagtype(6)=' quadrupole offset in y'
      cmagtype(7)=' orbit correction in x'
      cmagtype(8)=' orbit correction in y'
      cmagtype(9)=' solenoid field'
      cmagtype(10)=' undulator offset in x'
      cmagtype(11)=' undulator offset in y'

c
      do i=1,11
         if ((imz(i).gt.1).and.(imz(i).lt.nstepz)) then
            j=printerr(errmagshort,cmagtype(i))
         endif
      enddo
      return
      end ! of chk_maglen
c
c
      subroutine getmagfileinfo(line)
c     =================================================================
c     extract information from beamfile
c     -----------------------------------------------------------------
c
      include 'genesis.def'
      include 'magnet.cmn'
c
      character*(*) line
      integer n,i,idx,ierr
      real*8  val
c
      n=len(line)
      call getfirstchar(line,idx) ! get first character should be identical to index !!
c
c     version number
c
      i=index(line,'VERSION') !check for version number
      if ((i.gt.0).and.(i.eq.idx)) then
        ierr=extractnumber(line(i+7:n),val)
        if (ierr.lt.0) then
           i=printerr(errinwarn,
     c               'Unrecognized information line in maginfile')
        else
           magversion=val
        endif
        return
      endif 
c
c
      i=index(line,'UNITLENGTH') !check for unit length
      if ((i.gt.0).and.(i.eq.idx)) then
        ierr=extractnumber(line(i+7:n),val)
        if (ierr.lt.0) then
           i=printerr(errinwarn,
     c               'Unrecognized information line in maginfile')
        else
           unitlength=val
        endif
        return
      endif 
c
c     unrecognized
c
      i=printerr(errinwarn,'Unrecognized information line in beamfile')
      return
      end
c


