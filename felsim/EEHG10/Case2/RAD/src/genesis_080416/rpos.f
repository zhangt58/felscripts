      subroutine rpos(istepz,xx,yy)
c     ==================================================================
c     locates the position of the electron on its actual trajectory
c     apply orbit correction to account for wiggle motion.
c     ------------------------------------------------------------------
c
      include 'genesis.def'
      include 'field.cmn'
      include 'input.cmn'
      include 'magnet.cmn'
      include 'particle.cmn'
      include 'sim.cmn'
      
c
      real*8 x,awtmp,wxlow,wylow,xx(*),yy(*)
      integer ip,ix1,iy1,ix2,iy2,istepz
c
      x=(dble(istepz)+0.5)*delz*twopi
c
c     orbit correction ?
c     -------------------------------------------------------------------
      if (iorb.eq.0) then
        do ip=1,npart                   !no orbit correction
	   xporb(ip)=xx(ip)
	   yporb(ip)=yy(ip)
        end do
      else
        if (iwityp.eq.0) then
           do ip=1,npart                                 !planar undulator
              awtmp=dsqrt(faw2(istepz,xx(ip),yy(ip)))   !aw at particle position
	      xporb(ip)=xx(ip)-awtmp*dsin(x)/gamma0
              yporb(ip)=yy(ip) 
           end do 
        else
           do ip=1,npart                                 !helical undulator
              awtmp=dsqrt(faw2(istepz,xx(ip),yy(ip)))   !aw at particle position
	      xporb(ip)=xx(ip)-awtmp*dsin(x)/gamma0
              yporb(ip)=yy(ip)-awtmp*dcos(x)/gamma0 
           end do 
        end if
      end if
c
c     linear interpolation
c     -----------------------------------------------------------
      do ip=1,npart  
         ix1=int((xporb(ip)+dgrid*xkw0)/dxy)+1            !index in cartesian mesh
         iy1=int((yporb(ip)+dgrid*xkw0)/dxy)+1
         if (xporb(ip).lt.-dgrid*xkw0) then
           ix1=1
           ix2=1
           wxlow=0.d0
           lost=lost+1
           lostid(ip)=1
         else 
           if (xporb(ip).ge.dgrid*xkw0) then
             ix1=ncar
             ix2=ncar
             wxlow=1.d0
             lost=lost+1
             lostid(ip)=1
           else
             ix2=ix1+1
             wxlow=xporb(ip)+dgrid*xkw0-dxy*float(ix1-1)
             wxlow=1.d0-wxlow/dxy
           end if
         end if
         if (yporb(ip).lt.-dgrid*xkw0) then
           iy1=1
           iy2=1
           wylow=0.d0
           lost=lost+1 
           lostid(ip)=1
         else 
           if (yporb(ip).ge.dgrid*xkw0) then
             iy1=ncar
             iy2=ncar
             wylow=1.d0
             lost=lost+1
             lostid(ip)=1
           else
             iy2=iy1+1
             wylow=yporb(ip)+dgrid*xkw0-dxy*float(iy1-1)
             wylow=1.d0-wylow/dxy
           end if
         end if
         ipos(1,ip)=(iy1-1)*ncar+ix1 
         ipos(2,ip)=(iy2-1)*ncar+ix1 
         ipos(3,ip)=(iy1-1)*ncar+ix2 
         ipos(4,ip)=(iy2-1)*ncar+ix2 
         wx(ip)=wxlow
         wy(ip)=wylow 
      end do       ! ip
c
      return
      end
c


      subroutine getpsi(psi)
c     ==================================================================
c     calculates the total phase psi as the sum of the radiation phase phi
c     and the particla phase theta.
c     getpsi is only called by outpart to get a non moving bucket.
c     ------------------------------------------------------------------
c
      include 'genesis.def'
      include 'field.cmn'
      include 'input.cmn'
      include 'particle.cmn'
c
      real*8 philoc,wei,psi(npmax)
      integer ip,idx
      complex*16 clocal
c
      do ip=1,npart
        wei=wx(ip)*wy(ip)
        idx=ipos(1,ip)
        clocal=wei*crfield(idx)
        wei=wx(ip)*(1.d0-wy(ip))
        idx=ipos(2,ip)
        clocal=clocal+wei*crfield(idx)
        wei=(1.d0-wx(ip))*wy(ip)
        idx=ipos(3,ip)
        clocal=clocal+wei*crfield(idx)
        wei=(1.d0-wx(ip))*(1.d0-wy(ip))
        idx=ipos(4,ip)
        clocal=clocal+wei*crfield(idx)
        philoc=datan2(dimag(clocal),dble(clocal))
        psi(ip)=philoc+theta(ip) 
      end do   !ip
      return  
      end     !getpsi
