      subroutine mpi_merge

      include 'genesis.def'
      include 'mpi.cmn'
      include 'input.cmn'
      include 'io.cmn'
      include 'field.cmn'
c
      integer i,ih,islice,mpi_tmp,status(MPI_STATUS_SIZE)
      character*80  command

      if (iphsty.le.0) return  ! no output at all
c
c     mpi requires some synchronization to guarantee that all files have been written
c
      if (mpi_id.gt.0) then
         call MPI_SEND(mpi_id,1,MPI_INTEGER,0,0,MPI_COMM_WORLD,mpi_err)
         return
      else
        do i=1,mpi_size-1
          call MPI_RECV(mpi_tmp,1,MPI_INTEGER,i,0,MPI_COMM_WORLD,
     c                     status,mpi_err)
        enddo
      endif
c
c     mergin main output files
c
      do islice=firstout+1,nslice
       if (mod(islice,ishsty).eq.0) then
         write(command,10) outputfile(1:strlen(outputfile)),islice,
     c                     outputfile(1:strlen(outputfile)) 
         call system(command)
         write(command,20) outputfile(1:strlen(outputfile)),islice
         call system(command)
       endif
      enddo
c
c     merging particle binary output
c
      if ((ippart.gt.0).and.(ispart.gt.0)) then
        do islice=firstout+1,nslice
          write(command,30) outputfile(1:strlen(outputfile)),islice,
     c                     outputfile(1:strlen(outputfile)) 
          call system(command)
          write(command,40) outputfile(1:strlen(outputfile)),islice
          call system(command)
        enddo
      endif
      if (idmppar.ne.0) then
        do islice=firstout+1,nslice
          write(command,31) outputfile(1:strlen(outputfile)),islice,
     c                     outputfile(1:strlen(outputfile)) 
          call system(command)
          write(command,41) outputfile(1:strlen(outputfile)),islice
          call system(command)
        enddo
      endif
c 
c
c     merging field binary output
c
      if ((ipradi.gt.0).and.(isradi.gt.0)) then
        do islice=firstout+1,nslice
          write(command,50) outputfile(1:strlen(outputfile)),islice,
     c                     outputfile(1:strlen(outputfile)) 
          call system(command)
          write(command,60) outputfile(1:strlen(outputfile)),islice
          call system(command)
        enddo
        do ih=2,nhloop
          do islice=firstout+1,nslice
           write(command,70) outputfile(1:strlen(outputfile)),hloop(ih)
     c        ,islice,outputfile(1:strlen(outputfile)) ,hloop(ih)
           call system(command)
           write(command,80) outputfile(1:strlen(outputfile)),hloop(ih)
     c                   ,islice
           call system(command)
         enddo
        enddo
      endif
      if (idmpfld.ne.0) then
        do islice=firstout+1,nslice
          write(command,51) outputfile(1:strlen(outputfile)),islice,
     c                     outputfile(1:strlen(outputfile)) 
          call system(command)
          write(command,61) outputfile(1:strlen(outputfile)),islice
          call system(command)
        enddo
        do ih=2,nhloop
          do islice=firstout+1,nslice
           write(command,71) outputfile(1:strlen(outputfile)),hloop(ih)
     c        ,islice,outputfile(1:strlen(outputfile)) ,hloop(ih)
           call system(command)
           write(command,81) outputfile(1:strlen(outputfile)),hloop(ih)
     c                   ,islice
           call system(command)
         enddo
        enddo
      endif
c 

 
      return
 10   format('less ',a,'.slice',I6.6,' >> ',a)
 20   format('rm ',a,'.slice',I6.6)
 30   format('cat ',a,'.par.slice',I6.6,' >> ',a,'.par')
 40   format('rm ',a,'.par.slice',I6.6)
 31   format('cat ',a,'.dpa.slice',I6.6,' >> ',a,'.dpa')
 41   format('rm ',a,'.dpa.slice',I6.6)
 50   format('cat ',a,'.fld.slice',I6.6,' >> ',a,'.fld')
 60   format('rm ',a,'.fld.slice',I6.6)
 70   format('cat ',a,'.fld',I1.1,'.slice',I6.6,' >> ',a,'.fld',I1.1)
 80   format('rm ',a,'.fld',I1.1,'.slice',I6.6)
 51   format('cat ',a,'.dfl.slice',I6.6,' >> ',a,'.dfl')
 61   format('rm ',a,'.dfl.slice',I6.6)
 71   format('cat ',a,'.dfl',I1.1,'.slice',I6.6,' >> ',a,'.dfl',I1.1)
 81   format('rm ',a,'.dfl',I1.1,'.slice',I6.6)

      return
      end


