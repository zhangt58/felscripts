      function extractnumber(line,val)
c     ======================================================================
c     extract float from line, ignoring preceeding '='-signs
c     ======================================================================
c
      character*(*) line
      character*(255) cline
      real*8 val
      integer extractnumber,i,n,j
c
      extractnumber=0
      n=len(line)   
      i=index(line,'=')+1         !find equal sign
      cline=line(i:n)             !cut string
      call getfirstchar(cline,j)  !check if string is empty
      if (j.eq.0) then            
         extractnumber=-1
         return
      endif
      read(cline,*) val
      return
      end
c
      function extractval(line,values,nval)
c     ======================================================================
c     extract nval data out of line
c     ======================================================================
c
      character*(*) line
      character*(255) cline
      real*8 values(*)
      integer i,j,nval,ix1,ix2,extractval
c
      extractval=0
      cline=line
      do i=1,nval   
         call getfirstchar(cline,ix1) !check for characters
         if (ix1.eq.0) then !empty string
            extractval=-1    
            return
         endif
         ix2=255             !search backwards
         do j=255,ix1+1,-1   !for first space after ix1
           if (cline(j:j).eq.' ') ix2=j  
         enddo
         line=cline(ix1:ix2)    !copy word
         read(line,*) values(i) !get value
         line=cline(ix2:255)    !copy remaining part of the line
         cline=line             !to cline
      enddo
      return
      end
c
      subroutine getfirstchar(line,idx)
c     ======================================================================
c     get the index of the first non space character
c     ======================================================================
c  
      character*(*) line
      integer idx,i 
c
      idx=0
      do i=1,len(line)
         if ((line(i:i).gt.' ').and.(idx.lt.1)) idx=i
      enddo
      return
      end
c
      subroutine touppercase(c)
c     ======================================================================
c     convert string to upper case letters
c     ======================================================================
c
      character*(*) c
      integer i,ic

      do i=1,len(c)
         ic=ichar(c(i:i))
         if ((ic.gt.96).and.(ic.lt.123)) then
            ic=ic-32
            c(i:i)=char(ic)  !replace with uppercase character
         endif 
      enddo   
      return
      end
c
      function strlen(line)
c     ===================================================================
c     check length of given string
c     ===================================================================
c
      integer nchar, nchar1,len,strlen
      character*(*) line

      strlen=1
      nchar1=len(line)
 999  nchar=index(line(nchar1:nchar1),' ')
      if(nchar.ne.0) then
         if(nchar1.gt.1) then
            nchar1=nchar1-1
            goto 999
         endif
      endif
      strlen = nchar1
c
      return
      end
c
c
