***********************************************************************
      subroutine levitus_t(rd)
      implicit none
      include 'usr.com'
      include 'lev.com'
      integer k,klev,kk
      logical rd
      character*15 filename
      real tatmmax,tatmmin,dep

      filename = 'levitus.temp'

      if (rd) then
        if (TRES .eq. 0) filename = 'flux.temp'
c
c TRES = 1 :  read Levitus SST for internal restoring from 'levitus.temp'
c             created by this routine, with rd = .false.
c TRES = 0 :  read fluxes implied by internal relaxation from `flux.temp'
c             diagnosed by routine `diagnose_tflux.
c             Subtract integral for accuracy reasons.
c
        write(99,*) 'read temperature forcing from: ',filename
        call read_internal_forcing(filename,ftlev,34)
        if (TRES.eq.0) call qint3(ftlev)
      else

        write(99,*) 'levitus temperature interpolation:'
        write(99,*) 'model: level  depth   levitus: level  
     >    depth   max'
        do k=l,1,-1
          dep = -z(k)*hdim
          do kk=1,nlev
             if (depth(kk).le.dep) klev = kk
          enddo
          call levitus_interpol(topdir//'levitus/new/t00an1',
     &                            tatm,-5.,50.,k,klev)
          tatmmax = maxval(tatm)
          tatm = tatm - t0 
          ftlev(:,:,k) = tatm
          write(99,999) k,dep,klev,depth(klev),tatmmax
        enddo
c
        write(99,*) 'write levitus temperature field to: ',filename
        call write_internal_forcing(filename,ftlev,34)
c
      endif
      tatm = ftlev(:,:,l)
c
 999  format(2(10x,i3,f9.3),2f8.3)

      end
***********************************************************************
      subroutine levitus_s(rd)
      implicit none
      include 'usr.com'
      include 'lev.com'
      integer k,klev,kk
      logical rd
      character*15 filename
      real emipmax,dep

      filename = 'levitus.salt'

      if (rd) then 
        if (SRES .eq. 0) filename = 'flux.salt'
c
c SRES = 1 :  read Levitus SSS for internal restoring from 'levitus.salt'
c             created by this routine, with rd = .false.
c SRES = 0 :  read fluxes implied by internal relaxation from `flux.salt'
c             diagnosed by routine `diagnose_sflux.
c             Subtract integral for accuracy reasons.
c
        write(99,*) 'read salt forcing from: ',filename
        call read_internal_forcing(filename,fslev,33)
        if (SRES.eq.0) call qint3(fslev)
      else
        write(99,*) 'levitus salinity interpolation:'
        write(99,*) 'model: level  depth   levitus: level  
     >    depth   max'
        do k=l,1,-1
          dep = -z(k)*hdim
          do kk=1,nlev
             if (depth(kk).le.dep) klev = kk
          enddo
          call levitus_interpol(topdir//'levitus/new/s00an1',emip,
     &                 30.,40.,k,klev)
          emipmax = maxval(emip)
          emip = emip - s0 
          fslev(:,:,k) = emip
          write(99,999) k,dep,klev,depth(klev),emipmax
        enddo
c
        write(99,*) 'write levitus salinity field to: ',filename
        call write_internal_forcing(filename,fslev,33)
c
      endif
      emip = fslev(:,:,l)
c
 999  format(2(10x,i3,f9.3),2f8.3)

      end
***********************************************************************
      subroutine levitus_sst
      implicit none
      include 'usr.com'
      real tatmmax

      call levitus_interpol(topdir//'levitus/new/t00an1',tatm,
     >                                               -5.,50.,l,1)
      call write_forcing('temp',tatm,34)
      tatm = tatm - t0 
      tatmmax = maxval(tatm)
      write(99,*) 'fit of levitus temp field done, tatmmax =',tatmmax+t0

      end
***********************************************************************
      subroutine levitus_sal
      implicit none
      include 'usr.com'
      real emipmax

      call levitus_interpol(topdir//'levitus/new/s00an1',emip,
     >                                                     30.,40.,l,1)
      call write_forcing('salt',emip,33)
      emip = emip - s0 
      emipmax = maxval(emip)
      write(99,*) 'fit of levitus salt field done, emipmax =',emipmax+s0

      end
***********************************************************************
      subroutine levitus_interpol(filename,forc,lolimit,uplimit,k,klev)
c
c This interpolation routine uses all Levitus points that fall within 
c the model gridbox under consideration, rather than using only the
c closests data points.
c 
      include 'usr.com'
* IMPORT/EXPORT
      character*(*) filename
      real     forc(n,m), lolimit, uplimit
      integer  k, klev
* LOCAL
      real     xi, yj, for
      integer  i, j, ii, jj, kl, nmis
      integer  weight,iim,iip,jjm,jjp
      real     xilow, xihigh, yilow, yihigh
      integer  iilow, iihigh, jjlow, jjhigh
      integer, parameter :: nx  = 360
      integer, parameter :: ny  = 180
      real,    parameter :: missing = -99.9999
      real     dat(0:nx, ny)
  
      open(1,file=filename,form='formatted',action='read')
      do kl=1,klev
        read(1,'(10f8.4)') ((dat(i,j),i=1,nx),j=1,ny)
      enddo
      close(1)
      dat(0,:) = dat(nx,:)

      do i=0,nx
      do j=1,ny
          if (dat(i,j).gt.(missing+10.0)) then
            if (dat(i,j).gt.uplimit) dat(i,j) = uplimit
            if (dat(i,j).lt.lolimit) dat(i,j) = lolimit
          endif
      enddo
      enddo
cw    where( dat < lolimit ) dat = lolimit
cw    where( dat > uplimit ) dat = uplimit
*
      forc   = missing/20.
      do j = 1, m
        do i = 1, n
          if (landm(i,j,k).eq.OCEAN) then
            nmis   = 0
            xilow  = 180.*(x(i)-0.5*dx)/pi
            xihigh = 180.*(x(i)+0.5*dx)/pi
            iilow  = ceiling(xilow)
            iihigh = floor(xihigh)
            if (iilow .lt.0)  iilow = 0 
            if (iihigh.gt.nx) iihigh = nx
*
            yjlow  = 180.*(y(j)-0.5*dy)/pi
            yjhigh = 180.*(y(j)+0.5*dy)/pi
            jjlow  = ceiling(yjlow+90.5)
            jjhigh = floor(yjhigh+90.5)
*
 100        continue
            call interpol(iilow,iihigh,jjlow,jjhigh,dat,for,weight)
*
            if (weight.eq.0) then
               nmis = nmis + 1
cw               write(99,*)'levitus miss at :',k,i,j, nmis
               iilow  = iilow - 1
               jjlow  = jjlow - 1
               iihigh = iihigh + 1
               jjhigh = jjhigh + 1
               if (iilow .lt.0)  iilow  = 0 
               if (jjlow .lt.1)  jjlow  = 1 
               if (iihigh.gt.nx) iihigh = nx
               if (jjhigh.gt.ny) jjhigh = ny
               if (nmis.ge.10) stop'definite levitus miss'
               goto 100
            endif
            forc(i,j) = for/weight
            
c$$$            write(99,999) i,j,x(i)*180./pi,y(j)*180./pi,xilow,xihigh,
c$$$     >               yjlow,yjhigh,for, weight
          endif
        enddo
      enddo
*
* An additional smoothing can be done
*
c     call smooth(forc,k)

 999  format(2i3,6(1x,f9.3),f9.3,i3)
      end
*******************************************************************      
      SUBROUTINE interpol(iilow,iihigh,jjlow,jjhigh,dat,for,weight)
      implicit none
      include 'usr.com'
*     IMPORT/EXPORT
      integer, parameter :: nx  = 360
      integer, parameter :: ny  = 180
      real,    parameter :: missing = -99.9999
      real     dat(0:nx, ny)
      integer  iilow,iihigh,jjlow,jjhigh,weight
      real     for
*     LOCAL
      integer ii,jj

      weight = 0
      for  = 0.0
      do ii = iilow, iihigh
        do jj = jjlow, jjhigh
          if (dat(ii,jj).gt.(missing+10.0)) then
            for    = for + dat(ii,jj)
            weight = weight + 1
          endif
        enddo
      enddo

      end           
*******************************************************************      
      SUBROUTINE smooth(forc,k)
      implicit none
      include 'usr.com'
      
      integer i,j,k,iip,iim,jjp,jjm,weight
      real forc(n,m),forc1(n,m)
 
      forc1 = forc
      do j = 1, m
      do i = 1, n
        if (landm(i,j,k).eq.OCEAN) then
          iip = i+1
          iim = i-1
          jjp = j+1
          jjm = j-1
          if (iip.gt.n) iip = iip-n
          if (iim.lt.1) iim = iim+n
          if (jjp.gt.m) jjp = m
          if (jjm.lt.1) jjm = 1
          weight     = 1
          if (landm(iip,j,k).eq.OCEAN) then
             forc1(i,j) = forc1(i,j) + forc(iip,j) 
             weight     = weight + 1
          endif
          if (landm(iim,j,k).eq.OCEAN) then
             forc1(i,j) = forc1(i,j) + forc(iim,j) 
             weight     = weight + 1
          endif
          if (landm(i,jjp,k).eq.OCEAN) then
             forc1(i,j) = forc1(i,j) + forc(i,jjp) 
             weight     = weight + 1
          endif
          if (landm(i,jjm,k).eq.OCEAN) then
             forc1(i,j) = forc1(i,j) + forc(i,jjm) 
             weight     = weight + 1
          endif
          forc1(i,j) = forc1(i,j)/weight
        endif
      enddo
      enddo
      forc = forc1
      end
