      subroutine source(istepz, i)
c     ==================================================================
c     construct the source for the wave equation
c     = radiation of the electron beam
c     ------------------------------------------------------------------
c
      include 'genesis.def'
      include 'field.cmn'
      include 'input.cmn'
      include 'magnet.cmn'
      include 'particle.cmn'
      include 'work.cmn'
c
      integer ip,j,idx,istepz,i
      complex*16 ctemp,ctmp
      real*8 stemp,wei,evencoupling,awloc,rtmpy
      character*30 file
c
c
      do j=1,ncar*ncar
	     crsource(j)= (0.d0,0.d0)     !clear 2d array
      end do     ! j
c
      if (awz(istepz).lt.tiny) return        !drift !!!
c
      stemp=0.5d0*vacimp/eev*xcuren/float(npart)*xlamd/xlamds
      stemp=stemp*delz*twopi/dxy/dxy/2.d0  !constant factor 2 because source term is used twice
c
c     debugged - adding harmonic number to the source term
c
      stemp=stemp*dble(i)
c
c
c
      call rpos(istepz,xpart,ypart)      !get particle position on grid
c
      if (mod(i,2).ne.0) then
c
c     calculating the odd harmonics 
c
        do ip=1,npart                  !get undulator field at particle position
         p1(ip)=dsqrt(faw2(istepz,xporb(ip),yporb(ip)))
     c         *stemp/gamma(ip)/btpar(ip)*besselcoupling(i)
         cpart1(ip)=dcmplx(0.0,p1(ip))
        enddo       ! ip
c
      else
c
c     calculate the even harmonics, given by i
c
        evencoupling=dble(i)*xlamd/xlamds
        
	do ip=1,npart
           awloc=dsqrt(faw2(istepz,xporb(ip),yporb(ip)))
           p1(ip)=awloc*stemp/gamma(ip)/btpar(ip)*besselcoupling(i)
           p1(ip)=p1(ip)/gamma(ip)/gamma(ip)*                      ! nk K /gamma0 / k_u *x' -> x' = px/gamma
     +       evencoupling*awloc
           cpart1(ip)=-p1(ip)*dcmplx(sqrt(2.)*px(ip),0)      ! pi/2 phase shift due to coupling with 'i' for planar undulator
        enddo
      endif  
c
c     load source term with local bunching factor  
c

        do ip=1,npart
          ctemp=cpart1(ip)
     +       *dcmplx(dcos(dble(i)*theta(ip)),-dsin(dble(i)*theta(ip)))
          wei=wx(ip)*wy(ip)
          idx=ipos(1,ip)
          crsource(idx)=crsource(idx)+wei*ctemp
          wei=wx(ip)*(1.d0-wy(ip))
          idx=ipos(2,ip)
          crsource(idx)=crsource(idx)+wei*ctemp
          wei=(1.d0-wx(ip))*wy(ip)
          idx=ipos(3,ip)
          crsource(idx)=crsource(idx)+wei*ctemp
          wei=(1.d0-wx(ip))*(1.d0-wy(ip))
          idx=ipos(4,ip)
          crsource(idx)=crsource(idx)+wei*ctemp        
        end do
c

      return
      end     !source
c
