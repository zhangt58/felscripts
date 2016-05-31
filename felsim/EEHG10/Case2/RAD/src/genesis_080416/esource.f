      subroutine esource(istepz,thet)
c     ==================================================================
c     calculates the space charge field.
c     all particle are discretized on a radial mesh for all
c     selected azimutal and longitudinal fourier modes.
c     ------------------------------------------------------------------
c
      include  'genesis.def'
      include  'input.cmn'
      include  'particle.cmn'
      include  'work.cmn'
c
      integer m,j,ip,ir,istepz
c
      complex *16 vn,coef,cma(nrgrid),cmb(nrgrid),cmc(nrgrid),
     +            crtmp1(nrgrid),crtmp2(nrgrid),cscsource(nrgrid),
     +            ctemp
      real*8 econst,rscmax,drsc,vol(nrgrid),xmid,ymid,xks,xkw0,
     +       rmid(nrgrid),rlog(nrgrid),rdig(nrgrid)      
      real*8 ezmax 
      real*8 thet
      dimension thet(*)
c
      if (nscz.le.0) return                       !no space charge selected
c

      xks=twopi/xlamds
      xkw0=twopi/xlamd

      xmid=0.0d0              !get centroid position   
      ymid=0.0d0
      do ip=1,npart
         xmid=xmid+xpart(ip)       
         ymid=ymid+ypart(ip)
      end do       ! i
      if (npart.gt.0) then
        xmid=xmid/dble(npart)   !mean value
        ymid=ymid/dble(npart)     
      endif
c      
      do ip=1,npart 
        ez(ip)=0.d0                               !clear old space charge field
        p1(ip)=(xpart(ip)-xmid)*(xpart(ip)-xmid)
        p1(ip)=p1(ip)+(ypart(ip)-ymid)*(ypart(ip)-ymid)
        p1(ip)=dsqrt(p1(ip))/xkw0
      enddo
c
c     grid size
c
      if (rmax0sc.gt.0) then
       rscmax=rmax0sc                           ! domainsize defined explicitly in input deck
      else  
       rscmax=p1(1)     
       do ip=2,npart
          if (p1(ip).gt.rscmax) rscmax=p1(ip)       !look for maximum radius  
       enddo
       rscmax=rscmax+5*gamma0/xks                ! add extra space for fringe field
      endif
c
c     initial set-up for the grid
c
      drsc=rscmax/float(nptr-1) 
      do ir=2,nptr
        vol(ir)=pi*drsc*drsc*(2.*ir-1)            !2d volume around grid point
        rlog(ir)=log(float(ir)/float(ir-1))       !log term of higher modes
        rdig(ir)=2.*pi*float(ir-1)                !diagonal terms above/below main diag. 
      end do
      vol(1)=pi*drsc*drsc                         !volume of origin            
      rlog(1)=log(0.5)                            !shielding radius
      rdig(1)=0.                                  !no lower element at origin
      rdig(nptr+1)=0.                             !no upper element at border 
c
      econst=vacimp/eev*xcuren/float(npart)/(xks+xkw0)  !source term normalization
      coef=dcmplx(1.d0/(xks**2-(xks+xkw0)**2),0.d0) !matrix normalisation 
c
c     get position on the grid
c
      do ip=1,npart
        iwork(ip)=int((p1(ip))/drsc)+1
        if (iwork(ip).lt.1) iwork(ip)=1
        if (iwork(ip).ge.nptr) iwork(ip)=nptr-1   
        p2(ip)=1-((iwork(ip))*drsc-p1(ip))/drsc             ! get weighting for grid index iwork(ip)  
        p2(ip)=1.

      enddo
c
c     get azimuthal angle if needed
c
      if (nscr.gt.0) then
        do ip=1,npart 
          p1(ip)=datan2(ypart(ip)-ymid,xpart(ip)-xmid)
        end do
      endif
c
c     loop over azimuthal and longitudinal modes
c
      do m=-nscr,nscr
c
        do ir=1,nptr
          rmid(ir)=-rdig(ir)-rdig(ir+1)-2.*pi*dble(m*m)*rlog(ir)             !main diagonal elements 
        end do
        rmid(nptr)=rmid(nptr)-2.*pi*float(nptr)     !direchlet boundary condition
c         
        if (m.eq.0) then
          do ip=1,npart
            cpart2(ip)=dcmplx(1.0,0.)
          end do
        else
          do ip=1,npart
            cpart2(ip)=dcmplx(dsin(m*p1(ip)),-dcos(m*p1(ip)))
          end do
        endif
c
        do j=1,nscz
          do ir=1,nptr
            cscsource(ir)=dcmplx(0.d0,0.d0)      !clear source  
          end do
          do ip=1,npart
            ir=iwork(ip)
            ctemp=cpart2(ip)*dcmplx(dcos(j*thet(ip)),-dsin(j*thet(ip)))
            cscsource(ir)=cscsource(ir)+p2(ip)*ctemp
            cscsource(ir+1)=cscsource(ir+1)+(1-p2(ip))*ctemp
          end do 
          do ir=1,nptr 
             vn=dcmplx(0.d0,econst/float(j)/vol(ir)) !complex norm. term
             cscsource(ir)=vn*cscsource(ir)            !scale source term (current density)
             cma(ir)=coef*dcmplx(rdig(ir)/j/j/vol(ir),0.d0)  !construct complex matrix
             cmb(ir)=(1.d0,0.d0)+coef*dcmplx(rmid(ir)/j/j/vol(ir),0.d0)
             cmc(ir)=coef*dcmplx(rdig(ir+1)/j/j/vol(ir),0.d0)
          end do 
c            
          call trirad(cma,cmb,cmc,cscsource,crtmp1,crtmp2,nptr) !solve equation
c
c       for debug purposes
c
c          if ((m.eq.0).and.(j.eq.1).and.(istepz.gt.0)) then
c             write(69,rec=2*istepz-1) (cscsource(ir),ir=1,nptr)
c             write(69,rec=2*istepz) (crtmp1(ir),ir=1,nptr)
c          endif
c
c
          do ip=1,npart                         !sum up fourier coefficient
             ir=iwork(ip)
             ctemp=dcmplx(dcos(j*thet(ip)),dsin(j*thet(ip)))
             ctemp=ctemp*conjg(cpart2(ip))
             ez(ip)=ez(ip)+2.*p2(ip)*dble(crtmp1(ir)*ctemp)
     +             +2.*(1-p2(ip))*dble(crtmp1(ir+1)*ctemp)
          end do
        end do
      enddo
c
      do ip=1,npart
         ez(ip)=ez(ip)/xkw0           !scale due to normalized z
      enddo

      return
      
      end 




      subroutine trirad(a,b,c,r,u,w,n)
c     ==================================================================
c     solve a tridiagonal system for radial mesh
c     only called by esource for space charge calculation
c     ------------------------------------------------------------------
c
      integer n,k
      complex*16 w(*),a(*),b(*),c(*),r(*),u(*),bet
c

      bet=b(1)
      u(1)=r(1)/bet
      do k=2,n
	 w(k)=c(k-1)/bet
	 bet=b(k)-a(k)*w(k)
	 u(k)=(r(k)-a(k)*u(k-1))/bet
      end do       ! k
      do k=n-1,1,-1
	 u(k)=u(k)-w(k+1)*u(k+1)
      end do       ! k
c
      return
      end     !trirad
