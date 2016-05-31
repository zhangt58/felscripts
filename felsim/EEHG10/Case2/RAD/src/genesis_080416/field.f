      subroutine field(ihloop)
c     ==================================================================
c     integrate the wave equation one step in z for cartesian mesh
c     using adi - methode (alternationg direction implicit)
c        1: u(n+1/2)=u(n)+alpha/2(dx u(n+1/2)+dy u(n))
c        2: u(n+1)=u(n+1/2)+alpha/2(dx u(n+1/2)+dy u(n+1))  
c        to use tridiag methode transpose data array:
c        (1)->u(n)->u(i,j)->u(j,i)->u(n)->(2)->transpose again 
c     ------------------------------------------------------------------
c
      include   'genesis.def'
      include   'field.cmn'
      include   'input.cmn'
c
      integer ioff
      integer ix,idx,i,ihloop,n
c
      ioff=(ihloop-1)*ncar*ncar   ! note that ihloop is the harmonic counter but not the harmonics!
c
c     homogenious part to right hand side of diff equation (1)
c     ------------------------------------------------------------------
c      
        do ix=1,ncar
          crhm(ix)=crsource(ix)+crfield(ix+ioff)
     +           +cstep(ihloop)*(crfield(ix+ioff+ncar)   ! boundary :field = 0 for ix-ncar
     +           -crfield(ix+ioff)*2.)        
        end do
        do idx=ncar+1,ncar*(ncar-1)
            crhm(idx)=crsource(idx)+crfield(idx+ioff)
     +              +cstep(ihloop)*(crfield(idx+ncar+ioff)
     +              +crfield(idx-ncar+ioff)-2.*crfield(idx+ioff))
        end do
        do idx=ncar*(ncar-1)+1,ncar*ncar
          crhm(idx)=crsource(idx)+crfield(idx+ioff)
     +           +cstep(ihloop)*(crfield(idx-ncar+ioff)          !boundary: field = 0 for ix+ncar
     +           -2.*crfield(idx+ioff))
        end do
c
c
c     neumann boundary condition
c     ------------------------------------------------------------------
c 
      
      if (lbc.ne.0) then
         idx=ncar*(ncar-1)
         do ix=1,ncar
            crhm(ix)=crhm(ix)+cstep(ihloop)
     +	    *crfield(ix+ncar+ioff)
            crhm(idx+ix)=crhm(idx+ix)
     +	    +cstep(ihloop)*crfield(idx+ix-ncar+ioff)
         enddo
      endif
c
c     solve the tridiagonal system 1
c     ------------------------------------------------------------------

      call tridagx(crmatc,crhm,crfield,ihloop)      
c
c
c     homogenious part to right hand side of diff equation (2)
c     ------------------------------------------------------------------
c
c
      do ix=1,ncar*(ncar-1)+1,ncar
         crhm(ix)=crsource(ix)+crfield(ix+ioff)
     +           +cstep(ihloop)*(crfield(ix+1+ioff)
     +           -2.*crfield(ix+ioff))
         do idx=ix+1,ix+ncar-2
            crhm(idx)=crsource(idx)
     +                +crfield(idx+ioff)
     +                +cstep(ihloop)*(crfield(idx+1+ioff)
     +                +crfield(idx-1+ioff)
     +                -2.*crfield(idx+ioff))
         enddo
         idx=ix+ncar-1
         crhm(idx)=crsource(idx)+crfield(idx+ioff)
     +           +cstep(ihloop)*(crfield(idx-1+ioff)
     +           -2.*crfield(idx+ioff))
      enddo 
c
c
c     neumann boundary condition
c     ------------------------------------------------------------------
c
      if (lbc.ne.0) then
         do ix=1,ncar
            idx=ncar*(ix-1)+1
            crhm(idx)=crhm(idx)
     +	    +cstep(ihloop)*crfield(idx+1+ioff)
            idx=idx+ncar-1
            crhm(idx)=crhm(idx)
     +	    +cstep(ihloop)*crfield(idx-1+ioff)
         enddo
      endif
c
c     solve the tridiagonal system 2
c     ------------------------------------------------------------------
c
      call tridagy(crmatc,crhm,crfield,ihloop)
c
      return
      end     !fieldcar
c
c
      subroutine tridagx(c,r,u,h)
c     ==================================================================
c     solve a tridiagonal system for cartesian mesh in x direction
c     cbet and cwet are precalculated in auxval
c     ------------------------------------------------------------------
c
      include 'genesis.def'
      include 'input.cmn'
      include 'field.cmn'

      integer k,i,h,ioff1,ioff2
      complex*16 c(*),r(*),u(*)
c
      ioff1=ncar*(h-1)
      ioff2=ncar*ioff1
c
      do i=0,ncar*(ncar-1),ncar
        u(i+1+ioff2)=r(i+1)*cbet(1+ioff1)
        do k=2,ncar
	  u(k+i+ioff2)=(r(k+i)-c(ioff1+k)
     +	  *u(k+i-1+ioff2))*cbet(k+ioff1)
        end do       ! k
        do k=ncar-1,1,-1
          u(k+i+ioff2)=u(k+i+ioff2)
     +	  -cwet(k+1+ioff1)*u(k+i+1+ioff2) 
        end do
      end do
c

      return
      end     !tridag
c
c
      subroutine tridagy(c,r,u,h)
c     tridagy(crmatc,crhm,crfield,ihloop)        
c     ==================================================================
c     solve a tridiagonal system for cartesian mesh in y direction
c     cbet and cwet are precalculated in auxval
c     ------------------------------------------------------------------
c
      include 'genesis.def'
      include 'field.cmn'
      include 'input.cmn'

      integer n,k,i,h,ioff1,ioff2
      complex*16 c(*),r(*),u(*)
c
      ioff1=ncar*(h-1)
      ioff2=ncar*ioff1
c
      do i=1,ncar
         u(i+ioff2)=r(i)*cbet(1+ioff1)
      enddo
      do k=2,ncar
         n=k*ncar-ncar
         do i=1,ncar
            u(n+i+ioff2)=(r(n+i)-c(ioff1+k)
     +	    *u(n+i-ncar+ioff2))*cbet(k+ioff1)
         enddo
      enddo
      do k=ncar-1,1,-1
         n=k*ncar-ncar 
         do i=1,ncar
            u(n+i+ioff2)=u(n+i+ioff2)
     +	    -cwet(k+1+ioff1)*u(n+i+ncar+ioff2)
         enddo
      enddo 
c
      return
      end     !tridag
c
c
c   
      subroutine getdiag(stepsize,gridsize,wavenumber)
c     ======================================================================
c     construct the diagonal matrix for field equation
c     do some precalculation for field solver
c     ----------------------------------------------------------------------
c
      include 'genesis.def'
      include 'input.cmn'
      include 'field.cmn'
      include 'work.cmn'
c
      integer icar,ix,ihloop
      real*8 mupp,mmid,mlow,rtmp,stepsize,gridsize,wavenumber 
      complex*16  cwrk1(ncmax),cwrk2(ncmax)
      dimension mupp(ncmax),mmid(ncmax),mlow(ncmax)
     
c
c     construction of the diagonal maxtrix for cartesian mesh
c     --------------------------------------------------------------------
      do ihloop=1,nhloop
        rtmp=0.25d0*stepsize/(wavenumber*dble(hloop(ihloop)))
        rtmp=rtmp/(gridsize*gridsize)                !factor dz/(4 ks dx^2)
        cstep(ihloop)=dcmplx(0.d0,rtmp)    !complex value - see field equation  
        if (lbc.ne.0) lbc=1        !boundary condition
        mupp(1)=rtmp         !one edge of mesh 
        mmid(1)=-dble(2-lbc)*rtmp   !boundary condition a=0 or da/dz=0 
        mlow(1)=0.d0          
        do ix=2,ncar-1
          mupp(ix)=rtmp        !inside of mesh -> 2nd derivation possible
          mmid(ix)=-2.d0*rtmp
          mlow(ix)=rtmp
        end do
        mupp(ncar)=0.d0       !other edge of mesh
        mmid(ncar)=-dble(2-lbc)*rtmp
        mlow(ncar)=rtmp
c
c     construct complex matrix crmat=(i-im) for
c     field equation  (i-im)*a(t+1)=(i+im)a(t)
c     -------------------------------------------------------------------------
c
        do icar=1,ncar
          cwrk1(icar)=-dcmplx(0.d0,mupp(icar))            !store value temporary in cwrk1
          cwrk2(icar)=(1.d0,0.d0)-dcmplx(0.d0,mmid(icar)) !same here
          crmatc(ncar*(ihloop-1)+icar)=-dcmplx(0.d0,mlow(icar))            !crmatc is used later in the code
        end do
c                                         
c     precalculated constants for tridiag subroutine
c     ------------------------------------------------------------------------ 

          cbet((ihloop-1)*ncar+1)=1./cwrk2(1)
          cwet((ihloop-1)*ncar+1)=0.
         do icar=2,ncar
	    cwet((ihloop-1)*ncar+icar)=cwrk1(icar-1)
     +	    *cbet((ihloop-1)*ncar+icar-1)
	    cbet((ihloop-1)*ncar+icar)=1./(cwrk2(icar)-
     +	    crmatc(ncar*(ihloop-1)+icar)*cwet((ihloop-1)*ncar+icar)) 
	 end do
      end do
      return
      end     !auxval
c
