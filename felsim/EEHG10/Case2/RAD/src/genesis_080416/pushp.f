      subroutine pushp(istepz,xkper0)
c     ==================================================================
c     advance the particles, using runge-kutta (fourth order) method
c     ------------------------------------------------------------------
c
      include 'genesis.def'
      include 'input.cmn'
      include 'particle.cmn'
      include 'work.cmn'
c
      integer n,istepz
      real*8  stpz,xkper0
c
      call track(istepz,xkper0)          !advance particle transversly half integragtion step
c
      call esource(istepz,theta)     ! update space charge field
c
      call partsorc(istepz)   !get source term at z0+delz/2
c
c     first step
c     ------------------------------------------------------------------
c
      do n=1,npart    ! clear work arrays
	   k2gg(n)=0.0
	   k2pp(n)=0.0
      end do       ! n
c
c     ode at z0
c
      call partsim(gamma,theta,k2gg,k2pp,istepz)
c
c     second step
c     ------------------------------------------------------------------
c
      stpz=0.5*delz*twopi
      do n=1,npart
c k1 = d/2 k2 + k1
	 gamma(n)=stpz*k2gg(n)+gamma(n)
	 theta(n)=stpz*k2pp(n)+theta(n)
c k3 = k2
	 k3gg(n)=k2gg(n)
	 k3pp(n)=k2pp(n)
c k2 = 0
	 k2gg(n)=0.0
	 k2pp(n)=0.0
      end do       ! n

c ode at z0+delz/2
c
      if (iscrkup.ne.0) then
        call esource(0,theta)     ! update space charge field
      endif     

      call partsim(gamma,theta,k2gg,k2pp,istepz)
c
c     third step
c     ------------------------------------------------------------------
c
      do n=1,npart
c k1 = d/2 k2 + k1
	   gamma(n)=stpz*k2gg(n)+gamma(n)
	   theta(n)=stpz*k2pp(n)+theta(n)
c k1 = -d/2 k3 + k1
	   gamma(n)=-stpz*k3gg(n)+gamma(n)
	   theta(n)=-stpz*k3pp(n)+theta(n)
c k3 = k2/6
	   k3gg(n)=k3gg(n)/6.0
	   k3pp(n)=k3pp(n)/6.0
c k2 = -k2/2
	   k2gg(n)=-k2gg(n)/2.0
	   k2pp(n)=-k2pp(n)/2.0
      end do       ! n
c
c ode at z0+delz/2
c
      if (iscrkup.ne.0) then
        call esource(0,theta)     ! update space charge field
      endif     
c
      call partsim(gamma,theta,k2gg,k2pp,istepz)
c
c     fourth step
c     ------------------------------------------------------------------
c
      stpz=delz*twopi
      do n=1,npart
c k1 = d k2 + k1
	   gamma(n)=stpz*k2gg(n)+gamma(n)
	   theta(n)=stpz*k2pp(n)+theta(n)
c k3 = -k2 + k3
	   k3gg(n)=-k2gg(n)+k3gg(n)
	   k3pp(n)=-k2pp(n)+k3pp(n)
c k2 = -2 k2
	   k2gg(n)=k2gg(n)*2.0
	   k2pp(n)=k2pp(n)*2.0
      end do       ! n
c
c ode at z0+delz
c
      if (iscrkup.ne.0) then
        call esource(0,theta)     ! update space charge field
      endif     
c
      call partsim(gamma,theta,k2gg,k2pp,istepz)
c
      do n=1,npart
	   gamma(n)=gamma(n)+stpz*(k3gg(n)+k2gg(n)/6.0)
	   theta(n)=theta(n)+stpz*(k3pp(n)+k2pp(n)/6.0)
      end do       ! n
c
      call track(istepz,xkper0)        !advance particle transversly half integragtion step
c
c     wakefields or other energy losses if selected
c
      if (dedz.ne.0.) then 
         do n=1,npart
            gamma(n)=gamma(n)+dedz
         enddo
      endif
c 
c     check for particles outside the gridd  
c
      call chk_loss
c
      return
      end     !pushp
c
c
c
      subroutine chk_loss
c     ========================================================================
c     checks for lost particles, reorganizing the particle arrays
c     ------------------------------------------------------------------------ 
c
      include 'genesis.def'
      include 'input.cmn'
      include 'particle.cmn'
c
      real*8  rtmp
      character*30 closs
      integer delip(npmax),mpart,j,k,i,idel
c
      if (lost.le.0) return            !no loss-initialized in cut-tail
c
      mpart=npart/nbins
      j=0  
c
      do k=0,nbins-2
         do i=1,mpart                         !run over one set of mirror particles
            if (lostid(i+k*mpart).ne.0) then  !lost ?
               j=j+1                          !count &
               delip(j)=i                     !get index
            endif                         
         enddo
         do i=1,j                             !make sure that the found particles
            lostid(delip(i)+(k+1)*mpart)=0    !are not countet in next set
         enddo
      enddo
c
      do i=1,mpart                            !search last set
         if (lostid(i+(nbins-1)*mpart).ne.0) then
            j=j+1
            delip(j)=i
         endif
      enddo
c
      do i=1,j
         do k=0,nbins-1
           gamma(delip(i)+k*mpart)=-1.
         enddo  
      enddo
c      
      idel=0          
      do i=1,npart 
         if (gamma(i).gt.0.) then
            gamma(i-idel)=gamma(i)  
            theta(i-idel)=theta(i)  
            xpart(i-idel)=xpart(i)
            ypart(i-idel)=ypart(i)
            px(i-idel)=px(i)
            py(i-idel)=py(i)
         else    
            idel=idel+1
         endif
         lostid(i)=0   !clear flags of lost particles
      enddo
c
      lost=0
c
c     get numbers right
c
      npart=npart-nbins*j 
      xcuren=xcuren*float(npart)/float(npart+nbins*j)           
      rtmp=1.d0-dble(npart)/dble(npart+nbins*j)
      if (rtmp.gt.0.01) then
         write(closs,100) rtmp*100.
         i=printerr(errpartloss,closs)
      endif   
c
 100  format(f4.0)
      return
      end              !chk_loss
c
c

