
      subroutine incoherent(awz)
c     ==================================================================
c     compute elnergy lost and spread due to synchrtron radiation
c     only correct for planar undulators (almost correct for helical)
c     from  draft by s. reichle, modified by p. elleaume  august 1999
c     the effect ofenergy loss and spread  has been tested successfully
c     with respect to e. saldin nima381 (1996) p 545-547
c     ------------------------------------------------------------------
c
c
      include  'genesis.def'
      include  'input.cmn'
      include  'particle.cmn'
c
      integer ip,mpart,k
      real*8 tmp2,gam0,dgamavg,dgamsig,xkw0,awz
c
      if (awz.lt.tiny) return  !drift section!
      if ((isravg.eq.0).and.(isrsig.eq.0)) return 
c
      xkw0=twopi/xlamd
      gam0=0.
      do ip=1,npart
         gam0=gam0+gamma(ip)
      enddo
      gam0=gam0/dble(npart)
c
c     increase of energy spread
c
      dgamsig=1.015d-27*(xkw0*awz)**2*(1.697*awz+
     +     1./(1.+1.88*awz+0.8*awz**2)) 
      if (iwityp.ne.0) then                              !helical undulator
         dgamsig=1.015d-27*(xkw0*awz)**2*(1.42*awz+
     +           1./(1.+1.5*awz+0.95*awz**2))
      endif
c
      dgamsig=dsqrt(dgamsig*gam0**4*xkw0*xlamd*delz)*sqrt(3.)
     c        *dble(isrsig) !sqrt(3) uniform distribution
c
c     average energy loss
c
      dgamavg=1.88d-15*(xkw0*gam0*awz)**2
     c        *delz*xlamd*dble(isravg)
c
      mpart=npart/dble(nbins)
      gam0=0.
      if  (isrsig.ne. 0) then
          do ip=1,mpart
             tmp2=(2.*ran1(iseed)-1.)*dgamsig
             gam0=gam0+tmp2
             do k=0,nbins-1
               gamma(ip+k*mpart)=gamma(ip+k*mpart)+tmp2
             enddo  
          enddo
      endif
      gam0=gam0/dble(mpart)
      if (gam0+dgamavg .ne. 0.) then
         do ip=1,npart
            gamma(ip)=gamma(ip)-gam0-dgamavg
         enddo
      endif
c
      return
      end     !sr
c


