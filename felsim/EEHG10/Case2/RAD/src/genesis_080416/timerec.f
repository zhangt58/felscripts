      subroutine opentimerec(n)
c     ==================================================================
c     opens a scratch-file for the time record if necessary
c     ------------------------------------------------------------------
c  
      include 'genesis.def'
      include 'timerec.cmn'
      include 'mpi.cmn'
c      
      integer n
c
      if (mpi_id.gt.0) return   ! only the head node is managing the time-record
c

      if (nofile.ne.0) then     !write crtime to disk?
        ntmp=13
        open(ntmp,status='scratch',access='direct',recl=n*n*16,err=100)
      endif
      return
c
 100  ntmp=printerr(erropen,'CRTIME-scratch')
      call last
      return
      end


      subroutine pushtimerec(cpush,n,irec)
c     ==================================================================
c     copies cpush into crtime array/file
c     ------------------------------------------------------------------

      include 'genesis.def'
      include 'timerec.cmn'
      include 'field.cmn'
      include 'mpi.cmn'

      integer n,it,irec,ioff,ioff2,iloop
      complex*16 cpush(n*n*nhmax)
c
      if (mpi_id.gt.0) return   ! only the head node is managing the time-record
c

      if (nofile.eq.0) then
         ioff=(irec-1)*n*n*nhloop
         do it=1,n*n*nhloop
            crtime(ioff+it)=cpush(it)
         enddo
      else 
         ioff=(irec-1)*nhloop
         do iloop=1,nhloop
           ioff2=ioff*n*n+(iloop-1)*n*n
           write(ntmp,rec=(ioff+iloop),err=10)         
     +             (cpush(it),it=1+ioff2,n*n+ioff2)
         enddo
      endif
      return
 10   it=printerr(errread,'CRTIME-scratch')
      call last
      return
      end  !of pushtimerec
c
c
      subroutine pulltimerec(cpull,n,irec)
c     ==================================================================
c     copies crtime array/file into cpush
c     ------------------------------------------------------------------

      include 'genesis.def'
      include 'timerec.cmn'
      include 'field.cmn'
      include 'mpi.cmn'

      integer n,it,irec,ioff,ioff2,iloop
      complex*16 cpull(n*n*nhmax)
c
      if (mpi_id.gt.0) return   ! only the head node is managing the time-record
c
      if (nofile.eq.0) then
         ioff=(irec-1)*n*n*nhloop 
         do it=1,n*n*nhloop
            cpull(it)=dcmplx(crtime(ioff+it))
         enddo
      else 
         ioff=(irec-1)*nhloop
         do iloop=1,nhloop
            ioff2=ioff*n*n+(iloop-1)*n*n
            read(ntmp,rec=(ioff+iloop),err=10) 
     +            (cpull(it),it=1+ioff2,n*n+ioff2)
         enddo
      endif
      return
 10   it=printerr(errread,'CRTIME-scratch')
      call last
      return

      end  !of pulltimerec


      subroutine closetimerec
c     ====================================================================
c     close the scratch file if necessary
c     --------------------------------------------------------------------
c
      include 'genesis.def'
      include 'timerec.cmn'
      include 'mpi.cmn'
c
      if (mpi_id.gt.0) return   ! only the head node is managing the time-record
c
      if (nofile.ne.0) close(ntmp)
      return
      end
