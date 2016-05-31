c     ############################################################# 
c
c             deusque dixit fiat lux et facta est lux
c 
c     #############################################################
c
c     genesis 1.3 is a time dependent fel code. the very basic structure
c     and the naming of most variables are taken from its precessor 
c     tda3d.
c    
c     particle integration:  runge-kutta 4th order
c     field integration:     alternating direction implicit-methode   
c     space charge field:    inversion of tridiagonal matrix 
c 
c     genesis 1.3 is a cpu and memory expensive program and migth 
c     exceed the requirement on older platforms. it can be partially
c     reduced by excluding time-dependent simulation or, as an
c     alternative, using a scratch file for most of the stored
c     information.
c
c
c     author:     sven reiche     (main algorithm, version 1.0)
c     co-author:  bart faatz      (external modules, version 1.0)
c                 pascal elleaume (quantum fluctuation)
c                 micheal borland (sdds)
c                 robert soliday  (sdds)
c                 Greg Penn       (conditioning, HGHG)
c                 Ati Meseck      (HGHG)
c   
c     ###############################################################
c    
c     genesis 1.3 was written in 1997 at desy, hamburg as a part
c     of my  ph.d.-thesis. i intended as an open-source project.
c     i'm willing to discuss with others about modifications,
c     found bugs and extensions which migth become official in the
c     release of the next version of genesis 1.3
c 
c     the current contact is 
c              reiche@physics.ucla.edu
c        
c         
c     sven reiche, ucla, 08/24/04
c
c     #################################################################
c     ------------------------------------------------------------------
c     main unit
c     ------------------------------------------------------------------
      program genesis
c
      include 'genesis.def' 
c
      include 'mpi.cmn'
c
      include 'sim.cmn'
      include 'input.cmn'
      include 'time.cmn'
      include 'field.cmn'
      include 'work.cmn'
      include 'magnet.cmn'
c
      integer islp,isep,lstepz,istepz,islice
c
      call MPI_INIT(mpi_err)
      call MPI_COMM_RANK(MPI_COMM_WORLD, mpi_id,mpi_err)
      call MPI_COMM_SIZE(MPI_COMM_WORLD, mpi_size,mpi_err) 
c
      call initio     !open files, read in input
c
      call initrun    !initialize simulation 
      call outglob    !output of global parameter (t-independent)
c
c     temporary file for debugging
c
c      open(69,file='debug.dat',status='unknown',access='direct',
c     +    recl=16*nptr)
c
c     start loop for each slice
c
      do islice=1+mpi_id,nslice,mpi_size   !loop for each slice
c
         mpi_loop=mpi_size
         if (islice-mpi_id.ge.nslice-mpi_size+1) 
     c       mpi_loop=mod(nslice,mpi_size)
         if (mpi_loop.eq.0) mpi_loop=mpi_size
c
c     initial loading
c 
        istepz=0
c
        call doscan(islice)           !update scan value
        call dotime(islice)           !calculate time-dependent parameters
c      
        call loadrad(islice)          !radiation field loading
        call loadbeam(islice,xkw0)    !particle loading
        call chk_loss                 !remove cut particle
c
        call openoutputbinmpi(islice) !open binary outputfile for mpi feature
c
        call output(istepz,islice,xkw0)
c
c       propagate beam for nu wiggler periods
c
  
        do islp=1,nslp                !loop over slippage (advance field)
           lstepz=nsep
           if (islp.eq.nslp)  lstepz=nstepz-(islp-1)*nsep !correct for last section
c
           do isep=1,lstepz                    !loop 'steady state' simulation
              istepz=istepz+1
              call stepz(istepz,xkw0)          !advance one step in z         
              call output(istepz,islice,xkw0)
           end do 
c
           if ((itdp.ne.0).and.(islp.lt.nslp)) then
                 call swapfield(islp)      !advance field in time dep. simulation
           endif
c
        end do             
        call outhist(islice)
        call outdump(islice)                   !dump rad + part if needed
        call closeoutputbinmpi()               !close binary files for mpi feature
      end do    
c
c     merge has to be done first so that the field dump is already
c     created and the records from the slippage field 
c     are written at the right position
c
c
      call mpi_merge               ! merge single outputfiles into one
c
      call outdumpslippage         !write slippage field, which escaped the e-bunch
c
c     temporary for debugging
c
c      close(69)
c
      call last   !end run
c
      end     ! main
c

