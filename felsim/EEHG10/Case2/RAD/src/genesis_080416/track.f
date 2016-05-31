      subroutine track(istepz,xkper0)
c     ==================================================================
c     calculates exact soultion for transverse motion
c     this subroutine is call before and after runge-kutta integration
c     of phase and energy
c     ------------------------------------------------------------------
c
      include 'genesis.def'
      include 'input.cmn'
      include 'magnet.cmn'
      include 'particle.cmn'
      include 'work.cmn'
c
      real*8 a1,a2,a3,xtmp,foc,omg,qx,qy,betpar0,xkper0,xoff,yoff
      integer ip,istepz
c
      delz=delz*0.5
c
      betpar0=1.+awz(istepz)**2                ! add weak focusing
      betpar0=dsqrt(1.d0-betpar0/gamma0/gamma0)
      qx= qfld(istepz)+xkx*xkper0**2*awz(istepz)**2/gamma0/betpar0
      qy=-qfld(istepz)+xky*xkper0**2*awz(istepz)**2/gamma0/betpar0
c     
c     calculate magnetic center of quadrupole
c
      xoff=0
      yoff=0
c
csven   the extra factor xkper0 comes from the normalization of x and y      
c
      if (abs(qx).gt.small) then 
       xoff=awdx(istepz)*xkx*xkper0*xkper0*awz(istepz)**2/gamma0/betpar0
       xoff= (xoff+qfld(istepz)*dqfx(istepz)*xkper0)/qx
      endif   
      if (abs(qy).gt.small) then
       yoff=awdy(istepz)*xky*xkper0*xkper0*awz(istepz)**2/gamma0/betpar0      
       yoff=(yoff-qfld(istepz)*dqfy(istepz)*xkper0)/qy
      endif   
      do ip=1,npart
       p1(ip)=xpart(ip)-xoff   ! position relative to magnetic center  
       p2(ip)=ypart(ip)-yoff   ! of quadrupole field
      enddo
c
      if (qx.eq.0.) then
         do ip=1,npart
            xpart(ip)=xpart(ip)+px(ip)*twopi*delz/gamma(ip)/btpar(ip)
         enddo
      else 
         if (qx.gt.0.) then
            do ip=1,npart
               foc=dsqrt(dabs(qx)/gamma(ip)/btpar(ip))
               omg=foc*delz*xlamd
               a1=dcos(omg)
               a2=dsin(omg)/foc
               a3=-a2*foc*foc
               xpart(ip)=a1*p1(ip)+a2*px(ip)/gamma(ip)/btpar(ip)*xkper0
               xpart(ip)=xpart(ip)+xoff
               px(ip)=a3*p1(ip)*gamma(ip)*btpar(ip)/xkper0+a1*px(ip)
            enddo
         else
            do ip=1,npart
               foc=dsqrt(dabs(qx)/gamma(ip)/btpar(ip))
               omg=foc*delz*xlamd
               a1=dcosh(omg)
               a2=dsinh(omg)/foc
               a3=a2*foc*foc
               xpart(ip)=a1*p1(ip)+a2*px(ip)/gamma(ip)/btpar(ip)*xkper0
               xpart(ip)=xpart(ip)+xoff
               px(ip)=a3*p1(ip)*gamma(ip)*btpar(ip)/xkper0+a1*px(ip)
            enddo
         endif
      endif
c
c     field error
c
      if (dabs(awerx(istepz)).gt.tiny) then
         do ip=1,npart
            px(ip)=px(ip)+awerx(istepz)*delz*twopi
csven            xpart(ip)=xpart(ip)+                         !kick at 0.5*delz
csven     +                awerx(istepz)*0.5*delz*twopi/gamma(ip)/btpar(ip) 
         enddo
      endif
c
c     solenoid field
c
      if (dabs(solz(istepz)).gt.tiny) then
         do ip=1,npart
            a1=solz(istepz)*delz*xlamd/gamma(ip) 
            px(ip)=px(ip)+a1*py(ip)
            xpart(ip)=xpart(ip)+0.5*a1/gamma(ip)/btpar(ip) !kick at 0.5*delz
         enddo
      endif
c      
c     and now for the y-plane
c
      if (qy.eq.0.) then
         do ip=1,npart
            ypart(ip)=ypart(ip)+py(ip)*delz*twopi/gamma(ip)/btpar(ip)
         enddo
      else 
         if (qy.gt.0.) then
            do ip=1,npart
               foc=dsqrt(dabs(qy)/gamma(ip)/btpar(ip))
               omg=foc*delz*xlamd
               a1=dcos(omg)
               a2=dsin(omg)/foc
               a3=-a2*foc*foc
               ypart(ip)=a1*p2(ip)+a2*py(ip)/gamma(ip)/btpar(ip)*xkper0
               ypart(ip)=ypart(ip)+yoff
               py(ip)=a3*p2(ip)*gamma(ip)*btpar(ip)/xkper0+a1*py(ip)
            enddo
         else
            do ip=1,npart
               foc=dsqrt(dabs(qy)/gamma(ip)/btpar(ip))
               omg=foc*delz*xlamd
               a1=dcosh(omg)
               a2=dsinh(omg)/foc
               a3=a2*foc*foc
               ypart(ip)=a1*p2(ip)+a2*py(ip)/gamma(ip)/btpar(ip)*xkper0
               ypart(ip)=ypart(ip)+yoff
               py(ip)=a3*p2(ip)*gamma(ip)*btpar(ip)/xkper0+a1*py(ip)
            enddo
         endif
      endif
c
      if (dabs(awery(istepz)).gt.tiny) then
         do ip=1,npart
            py(ip)=py(ip)+awery(istepz)*delz*twopi
csven            ypart(ip)=ypart(ip)
csven     +               +awery(istepz)*0.5*delz*twopi/gamma(ip)/btpar(ip) 
         enddo
      endif
c
c
c     solenoid field
c
      if (dabs(solz(istepz)).gt.tiny) then
         do ip=1,npart
            a1=solz(istepz)*delz*xlamd/gamma(ip) 
            py(ip)=py(ip)-a1*px(ip)
            ypart(ip)=ypart(ip)-0.5*a1/gamma(ip)/btpar(ip) !kick at 0.5*delz
         enddo
      endif
c      
      delz=delz*2.
c      
      return
      end 
