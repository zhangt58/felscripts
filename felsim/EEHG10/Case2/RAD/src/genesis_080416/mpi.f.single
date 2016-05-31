c     wrapper for stand-alone version  of genesis
c     most of the MPI routines are empty except for the initialization
c     where the size=1 and id=0 is assigned 
c
c     to compile for mpi, replce this file with mpi.f from the mpi 
c     subdirectory and remove the file mpif.h
c
c     ----------------------------------
      subroutine MPI_INIT(i1)
c   
      include 'genesis.def'
      include 'mpi.cmn'
c    
      integer i1
c
      mpi_size=1
      mpi_id=0
      return
      end
c     ---------------------------------
      subroutine MPI_BCAST(c,i1,i2,i3,i4,i5)
c
      character*(*) c
      integer i1,i2,i3,i4
c
      return
      end       
c     ---------------------------------
      subroutine MPI_SEND(c,i1,i2,i3,i4,i5,i6)
c
      complex*16 c
      integer    i1,i2,i3,i4,i5,i6
c
      return
      end 
c     ----------------------------------
      subroutine MPI_RECV(c,i1,i2,i3,i4,i5,i6,i7)
c
      complex*16 c
      integer i1,i2,i3,i4,i5,i6(1),i7
c
      return
      end
c     ----------------------------------
      subroutine MPI_COMM_RANK(i1,i2,i3)
c
      integer i1,i2,i3
c
      return
      end
c     ---------------------------------
      subroutine MPI_COMM_SIZE(i1,i2,i3)
c     
      integer i1,i2,i3
c
      return
      end
c     ----------------------------------
      subroutine MPI_FINALIZE(ierr)
      integer ierr
      return 
      end
c     -----------------------------------
      subroutine MPI_MERGE
      return
      end
