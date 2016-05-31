      subroutine loadrad(islice)
c     =========================================================
c     fills the array crfield with initial field
c     for start up from noise this should be small
c     ---------------------------------------------------------
c
      include 'genesis.def'
      include 'field.cmn'
      include 'input.cmn'
      include 'work.cmn'
      include 'io.cmn'
      include 'diagnostic.cmn'
      include 'time.cmn'
      include 'sim.cmn'
   
c
      real*8  pradin
      integer ix,irec,islice,ierr,n
c
c     initialize field
c     ---------------------------
      do ix=1,ncar*ncar*nhloop
        crfield(ix)=dcmplx(0.,0.)
      enddo
c
      pradoln(1)=prad0          !first halfstep no gain (see diagno)
      do n=2,nhmax
        pradoln(n)=0.d0  !kg
        if (n.eq.nharm) pradoln(n)=pradh0
      end do
c
c     load initial field
c     ------------------------------------------------------------------
c
c
      if (nfin.le.0) then
        call gauss_hermite(crfield,prad0,zrayl,
     +  zwaist,xks,radphase,1) !load gauss-hermite mode for all harmonics
        if ((nharm.gt.1).and.(pradh0.gt.0)) then
          call gauss_hermite(crfield,pradh0,zrayl*dble(nharm),
     +    zwaist,xks*dble(nharm),radphase,nharm) !load gauss-hermite mode for higher harmonics
        endif
      else
        irec=nslp-1+islice                 !get record number
        if (alignradf.ne.0) irec=offsetradf+islice ! add offset, when selected
        if (itdp.eq.0) irec=1              !scan+ss -> use 1sr record
        if (irec.gt.0) then				   ! physical record?
          ierr=readfield(crfield,irec)       !get fundamental field from file
          if (ierr.lt.0) call last           !stop if error occured
        else
          call gauss_hermite(crfield,prad0,zrayl*dble(nharm),
     +	  zwaist,xks*dble(nharm),radphase,1)
          if ((nharm.gt.1).and.(pradh0.gt.0)) then
            call gauss_hermite(crfield,pradh0,zrayl*dble(nharm),
     +      zwaist,xks*dble(nharm),radphase,nharm) !load gauss-hermite mode for all harmonics
          endif
        endif  
        pradin=0.d0
        do ix=1,ncar*ncar                  !copy to crfield
           pradin=pradin+dble(crfield(ix)*conjg(crfield(ix)))
        enddo 
        prad0=pradin*(dxy*eev*xkper0/xks)**2/vacimp
	pradoln(1)=prad0
      endif
      return
      end       !of loadrad
c
c
      subroutine gauss_hermite(cfld,power,zr,zw,rks,phase,harm)
c     =======================================================
c     fills array cfld with the fundamental gauss-hermite mode
c     using the total power, wavenumber rks, rayleigh length zr
c     and waist position zw.
c
c     Note - only the fundamental is loaded. harmonics are set to zero
c     --------------------------------------------------------
c
      include 'genesis.def'
      include 'sim.cmn'
      include 'field.cmn'
      include 'input.cmn'
      include 'diagnostic.cmn'

      complex*16 cfld(ncar*ncar*nhmax),cgauss
      real*8     zscal,xcr,ycr,rcr2,power,zr,zw,rks,phase
      integer    iy,ix,idx,n,harm,ioff
      real*8     dump
c
c     check for unphysical parameters
c
      idx=0
      if (zr.le.0) idx=printerr(errload,'zrayl in gauss_hermite')
      if (rks.le.0) idx=printerr(errload,'xks in gauss_hermite')
      if (power.lt.0) idx=printerr(errload,'power in gauss_hermite')
      if (idx.lt.0) call last
c
      ioff=ncar*ncar*(harm-1)             !offset for harmonics
      cgauss=0.5d0*rks/dcmplx(zr,-zw)     !see siegman
      zscal = dsqrt(2.d0*vacimp*power/pi *dble(cgauss))  
     +              *rks/xkper0**2/eev    !?
      dump=0.d0
      do iy=1,ncar
         do ix=1,ncar
             idx=(iy-1)*ncar+ix
             xcr=dxy*float(ix-1)/xkw0-dgrid
             ycr=dxy*float(iy-1)/xkw0-dgrid
             rcr2=xcr*xcr+ycr*ycr 
             cfld(idx+ioff)=
     +           zscal*cdexp(-cgauss*rcr2+dcmplx(0,1)*phase)  !gaussian beam
             dump=dump+dble(cfld(idx+ioff)*conjg(cfld(idx+ioff))) !=sum of |aij|^2 
         end do    !ix
      end do       !iy
      return
      end
c
      subroutine loadslpfld(nslp)
c     =========================================================
c     fills the array crtime with a seeding field for the first 
c     slice.
c     ---------------------------------------------------------
c
      include 'genesis.def'
      include 'input.cmn'
      include 'field.cmn'
      include 'work.cmn'
      include 'io.cmn'
      include 'timerec.cmn'
      include 'diagnostic.cmn'
c
      integer ix,islp,nslp,ierr,irec,i
c
      if (itdp.eq.0) return

c
c     check for limitation in timerecord                                          
c     ---------------------------------------------------------------             
c                                                                                 
      if (nslice.lt.nslp*(1-iotail))
     c  ierr=printerr(errlargeout,'no output - ntail too small')

      if (nofile.eq.0) then
         if (nslp*ncar*ncar*nhloop.gt.ntmax*nhmax) then
           ierr=printerr(errtime,' ')
           call last
         endif
      endif
c
c     load initial slippage field from file or internal generation 
c     ----------------------------------------------------------------
c


      do islp=1,nslp-1
c
        do ix=1,ncar*ncar*nhloop
          crwork3(ix)=dcmplx(0.,0.)   !initialize the radiation field
        enddo
c
        if (nfin.gt.0) then
            irec=islp
            if (alignradf.ne.0) then
               irec=irec-nslp+1+offsetradf
            endif
            if (irec.gt.0) then
              ierr=readfield(crwork3,irec)  !get field from file (record 1 - nslp-1)
              if (ierr.lt.0) call last      !record nslp is loaded with loadrad (s.a.)
            else
              pradoln(1)=prad0
              do i=2,nhmax
                pradoln(i)=0.
                if (i.eq.nharm) pradoln(i)=pradh0
              enddo
              call gauss_hermite(crwork3,prad0,zrayl,zwaist,xks,
     c                           radphase,1) 
              if ((nharm.gt.1).and.(pradh0.gt.0)) then
                 call gauss_hermite(crwork3,pradh0,zrayl*dble(nharm),
     +                        zwaist,xks*dble(nharm),radphase,nharm) !load gauss-hermite mode for higher harmonics
              endif
            endif   
         else
           call dotimerad(islp+1-nslp)      ! get time-dependence of slippage field behind bunch
           call gauss_hermite(crwork3,prad0,zrayl,zwaist,xks,radphase,1) !load gauss-hermite mode
           if ((nharm.gt.1).and.(pradh0.gt.0)) then
              call gauss_hermite(crwork3,pradh0,zrayl*dble(nharm),
     +                      zwaist,xks*dble(nharm),radphase,nharm) !load gauss-hermite mode for higher harmonics
           endif
           pradoln(1)=prad0
         endif            
         call pushtimerec(crwork3,ncar,nslp-islp)
      enddo   
      return
      end
c 
c
      subroutine swapfield(islp)
c     ========================================
c     swap current field with then time-record
c     ----------------------------------------
c
      include 'genesis.def'
      include 'mpi.cmn'
      include 'input.cmn'
      include 'field.cmn'
      include 'work.cmn'
c
      integer islp,it,mpi_top,mpi_bot
      integer memsize
      integer status(MPI_STATUS_SIZE)
c
      memsize=ncar*ncar*nhloop

      if (mpi_loop.gt.1) then
c
        do it=1,memsize
          crwork3(it)=crfield(it)
        enddo
c
        mpi_top=mpi_id+1
        if (mpi_top.ge.mpi_loop) mpi_top=0
        mpi_bot=mpi_id-1
        if (mpi_bot.lt.0) mpi_bot=mpi_loop-1      
c
        if (mod(mpi_id,2).eq.0) then
         call MPI_SEND(crwork3,memsize,MPI_DOUBLE_COMPLEX,mpi_top,
     c       mpi_id,MPI_COMM_WORLD,mpi_err)
         call MPI_RECV(crfield,memsize,MPI_DOUBLE_COMPLEX,mpi_bot,
     c       mpi_bot,MPI_COMM_WORLD,status,mpi_err)        
        else
         call MPI_RECV(crfield,memsize,MPI_DOUBLE_COMPLEX,mpi_bot,
     c       mpi_bot,MPI_COMM_WORLD,status,mpi_err)        
         call MPI_SEND(crwork3,memsize,MPI_DOUBLE_COMPLEX,mpi_top,
     c       mpi_id,MPI_COMM_WORLD,mpi_err)    
        endif    
      endif
      
      if (mpi_id.gt.0) return

      do it=1,memsize
          crwork3(it)=crfield(it)
      enddo

      call pulltimerec(crfield,ncar,islp)
      call pushtimerec(crwork3,ncar,islp)
      return
      end ! swapfield
