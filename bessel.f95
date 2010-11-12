module bessel

    real(kind=8) :: pi
    real(kind=8), dimension(0:20) :: a, b, afar
    real(kind=8), dimension(0:20) :: nrange
    real(kind=8), dimension(0:20,0:20) :: gam
    real(kind=8), dimension(8) :: xg, wg

contains

    subroutine initialize

        implicit none
        real(kind=8) :: c, fac
        integer :: n,m
        
        pi = 3.1415926535897931d0
        
        do n = 0, 20
            nrange(n) = dble(n)
        end do
        c = log(0.5d0) + 0.577215664901532860d0
        
        fac = 1.d0
        a(0) = 1.d0
        b(0) = 0.d0
        do n = 1, 20
            fac = n * fac
            a(n) = 1.0 / (4.0d0**nrange(n) * fac**2)
            b(n) = b(n-1) + 1.0d0 / nrange(n)
        end do
        b = (b-c) * a
        a = -0.5d0 * a
        
        do n = 0,20
            do m = 0,n
                gam(n,m) = product(nrange(m+1:n)) / product(nrange(1:n-m))
            end do
        end do
        
        afar(0) = sqrt(pi/2.d0)
        do n = 1,20
            afar(n) = -(2.d0*n - 1.d0)**2 / (n * 8.d0) * afar(n-1)
        end do
        
        !wg(1) = 0.10122853629037751d0
        !wg(2) = 0.22238103445337376d0
        !wg(3) = 0.3137066458778866d0
        !wg(4) = 0.36268378337836155d0
        !wg(5) = 0.36268378337836205d0
        !wg(6) = 0.3137066458778876d0
        !wg(7) = 0.22238103445337545d0
        !wg(8) = 0.10122853629037616d0
        !
        !xg(1) = -0.9602898564975364d0
        !xg(2) = -0.79666647741362595d0
        !xg(3) = -0.52553240991632855d0
        !xg(4) = -0.18343464249565006d0
        !xg(5) = 0.18343464249565022d0
        !xg(6) = 0.52553240991632888d0
        !xg(7) = 0.79666647741362673d0
        !xg(8) = 0.96028985649753629d0
        
        wg(1) = 0.101228536290378d0
        wg(2) = 0.22238103445338d0
        wg(3) = 0.31370664587789d0
        wg(4) = 0.36268378337836d0
        wg(5) = 0.36268378337836d0
        wg(6) = 0.313706645877890
        wg(7) = 0.22238103445338d0
        wg(8) = 0.10122853629038d0

        xg(1) = -0.960289856497536d0
        xg(2) = -0.796666477413626d0
        xg(3) = -0.525532409916329d0
        xg(4) = -0.183434642495650d0
        xg(5) = 0.183434642495650d0
        xg(6) = 0.525532409916329d0
        xg(7) = 0.796666477413626d0
        xg(8) = 0.960289856497536d0

        return

    end subroutine initialize
    
    function besselk0far(z, Nt) result(omega)
        implicit none
        complex(kind=8), intent(in) :: z
        integer, intent(in) :: Nt
        complex(kind=8) :: omega, term
        integer :: n

        term = 1.d0
        omega = afar(0)
        do n = 1, Nt
            term = term / z
            omega = omega + afar(n) * term
        end do
        omega = exp(-z) / sqrt(z) * omega

        return
    end function besselk0far
   
    function besselk0near(z, Nt) result(omega)
        implicit none
        complex(kind=8), intent(in) :: z
        integer, intent(in) :: Nt
        complex(kind=8) :: omega
        complex(kind=8) :: rsq, log1, term
        integer :: n
        
        rsq = z**2        
        term = cmplx(1.d0,0.d0,kind=8)
        log1 = log(rsq)
        omega = a(0) * log1 + b(0)
        
        do n = 1, Nt
            term = term * rsq
            omega = omega + (a(n)*log1 + b(n)) * term
        end do

        return
    end function besselk0near
    
    function besselk0cheb(z, Nt) result (omega)
        implicit none

        complex(kind=8), intent(in) :: z
        integer, intent(in) :: Nt
        complex(kind=8) :: omega

        integer :: n, n2, ts
        real(kind=8) :: a, b, c, A3, u
        complex(kind=8) :: A1, A2, cn, cnp1, cnp2, cnp3
        complex(kind=8) :: z1, z2, S, T
        
        cnp1 = cmplx( 1.d0, 0.d0, kind=8 )
        cnp2 = cmplx( 0.d0, 0.d0, kind=8 )
        cnp3 = cmplx( 0.d0, 0.d0, kind=8 )
        a = 0.5d0
        c = 1.d0
        b = 1.d0 + a - c

        z1 = 2.d0 * z
        z2 = 2.d0 * z1    
        ts = (-1)**(Nt+1)
        S = ts
        T = 1.d0
        
        do n = Nt, 0, -1
            u = (n+a) * (n+b)
            n2 = 2.d0 * n
            A1 = 1.d0 - ( z2 + (n2+3.d0)*(n+a+1.d0)*(n+b+1.d0) / (n2+4.d0) ) / u
            A2 = 1.d0 - (n2+2.d0)*(n2+3.d0-z2) / u
            A3 = -(n+1.d0)*(n+3.d0-a)*(n+3.d0-b) / (u*(n+2.d0))
            cn = (2.d0*n+2.d0) * A1 * cnp1 + A2 * cnp2 + A3 * cnp3
            ts = -ts
            S = S + ts * cn
            T = T + cn
            cnp3 = cnp2; cnp2 = cnp1; cnp1 = cn
        end do
        cn = cn / 2.d0
        S = S - cn
        T = T - cn
        omega = 1.d0 / sqrt(z1) * T / S
        omega = sqrt(pi) * exp(-z) * omega
        
    end function besselk0cheb
    
    function besselk0(x, y, lab) result(omega)
        implicit none
        real(kind=8), intent(in) :: x,y
        complex(kind=8), intent(in) :: lab
        complex(kind=8) :: z, omega
        real(kind=8) :: cond

        z = sqrt(x**2 + y**2) / lab
        cond = abs(z)
        
        if (cond < 6.d0) then
            omega = besselk0near( z, 17 )
        else
            omega = besselk0cheb( z, 6 )
        end if

        return
    end function besselk0
    
    function k0bessel(z) result(omega)
        implicit none
        complex(kind=8), intent(in) :: z
        complex(kind=8) :: omega
        real(kind=8) :: cond

        cond = abs(z)
        
        if (cond < 6.d0) then
            omega = besselk0near( z, 17 )
        else
            omega = besselk0cheb( z, 6 )
        end if

        return
    end function k0bessel
    
    subroutine besselk0v(x,y,lab,nlab,omega) 
        implicit none
        real(kind=8), intent(in) :: x,y
        integer, intent(in) :: nlab
        complex(kind=8), dimension(nlab), intent(in) :: lab
        complex(kind=8), dimension(nlab), intent(inout) :: omega
        integer :: n
        do n = 1,nlab
            omega(n) = besselk0(x, y, lab(n))
        end do
    end subroutine besselk0v
    
    subroutine k0besselv(z,nlab,omega) 
        implicit none
        integer, intent(in) :: nlab
        complex(kind=8), dimension(nlab), intent(in) :: z
        complex(kind=8), dimension(nlab), intent(inout) :: omega
        integer :: n
        do n = 1,nlab
            omega(n) = k0bessel(z(n))
        end do
    end subroutine k0besselv
    
    function besselk0OLD(x, y, lab) result(omega)
        implicit none
        real(kind=8), intent(in) :: x,y
        complex(kind=8), intent(in) :: lab
        complex(kind=8) :: z, omega
        real(kind=8) :: cond
        
        z = sqrt(x**2 + y**2) / lab
        cond = abs(z)
        
        if (cond < 4.d0) then
            omega = besselk0near( z, 12 )  ! Was 10
        else if (cond < 8.d0) then
            omega = besselk0near( z, 18 )
        else if (cond < 12.d0) then
            omega = besselk0far( z, 11 )  ! was 6
        else
            omega = besselk0far( z, 8 )  ! was 4
        end if

        return
    end function besselk0OLD
    
    function besselcheb(z, Nt) result (omega)
        implicit none
        integer, intent(in) :: Nt
        complex(kind=8), intent(in) :: z
        complex(kind=8) :: omega
        complex(kind=8) :: z2
        
        z2 = 2.0 * z
        
        omega = sqrt(pi) * exp(-z) * ucheb(0.5d0,1,z2,Nt)
        
    end function besselcheb
    
    function ucheb(a, c, z, n0) result (ufunc)
        implicit none
        integer, intent(in) :: c, n0
        real(kind=8), intent(in) :: a
        complex(kind=8), intent(in) :: z
        complex(kind=8) :: ufunc
        
        integer :: n, n2, ts
        real(kind=8) :: A3, u, b
        complex(kind=8) :: A1, A2, cn,cnp1,cnp2,cnp3
        complex(kind=8) :: z2, S, T
        
        cnp1 = 1.d0
        cnp2 = 0.d0
        cnp3 = 0.d0
        ts = (-1)**(n0+1)
        S = ts
        T = 1.d0
        z2 = 2.d0 * z
        b = 1.d0 + a - c
        
        do n = n0, 0, -1
            u = (n+a) * (n+b)
            n2 = 2.d0 * n
            A1 = 1.d0 - ( z2 + (n2+3)*(n+a+1)*(n+b+1.d0) / (n2+4.d0) ) / u
            A2 = 1.d0 - (n2+2.d0)*(n2+3.d0-z2) / u
            A3 = -(n+1)*(n+3-a)*(n+3-b) / (u*(n+2))
            cn = (2*n+2) * A1 * cnp1 + A2 * cnp2 + A3 * cnp3
            ts = -ts
            S = S + ts * cn
            T = T + cn
            cnp3 = cnp2; cnp2 = cnp1; cnp1 = cn
        end do
        cn = cn / 2.d0
        S = S - cn
        T = T - cn
        ufunc = z**(-a) * T / S
        
    end function ucheb
    

        
        
    
   
    function besselk0complex(x, y) result(phi)
        implicit none
        real(kind=8), intent(in) :: x,y
        real(kind=8) :: phi
        real(kind=8) :: d
        complex(kind=8) :: zeta, zetabar, omega, logdminzdminzbar, dminzeta, term
        complex(kind=8), dimension(0:20) :: zminzbar
        complex(kind=8), dimension(0:20,0:20) :: gamnew
        complex(kind=8), dimension(0:40) :: alpha, beta

        integer :: n
        
        d = 0.d0
        
        zeta = cmplx(x,y)
        zetabar = conjg(zeta)
        do n = 0,20
            zminzbar(n) = (zeta-zetabar)**(20-n)  ! Ordered from high power to low power
        end do
        gamnew = gam
        do n = 0,20
            gamnew(n,0:n) = gamnew(n,0:n) * zminzbar(20-n:20)
        end do
        
        alpha(0:40) = 0.d0
        beta(0:40) = 0.d0
        alpha(0) = a(0)
        beta(0) = b(0)
        do n = 1,20
            alpha(n:2*n) = alpha(n:2*n) + a(n) * gamnew(n,0:n)
            beta(n:2*n)  = beta(n:2*n)  + b(n) * gamnew(n,0:n)
        end do
        
        omega = 0.d0
        logdminzdminzbar = log( (d-zeta) * (d-zetabar) )
        dminzeta = d - zeta
        term = 1.d0
        do n = 0,40
            omega = omega + ( alpha(n) * logdminzdminzbar + beta(n) ) * term
            term = term * dminzeta
        end do

        phi = real(omega)

        return
    end function besselk0complex
    
    function bessellsreal(x,y,x1,y1,x2,y2,lab) result(phi)
        implicit none
        real(kind=8), intent(in) :: x,y,x1,y1,x2,y2,lab
        real(kind=8) :: phi, biglab, biga, L
        complex(kind=8) :: z1, z2, zeta, zetabar, omega, log1, log2, term1, term2, d1minzeta, d2minzeta
        complex(kind=8), dimension(0:20) :: zminzbar
        complex(kind=8), dimension(0:20,0:20) :: gamnew
        complex(kind=8), dimension(0:40) :: alpha, beta

        integer :: n
        
        z1 = dcmplx(x1,y1); z2 = dcmplx(x2,y2)
        L = abs(z2-z1)
        biga = abs(lab)
        biglab = 2.d0 * biga / L

        zeta = (2.d0 * dcmplx(x,y) - (z1+z2) ) / (z2-z1) / biglab 
        zetabar = conjg(zeta)
        do n = 0,20
            zminzbar(n) = (zeta-zetabar)**(20-n)  ! Ordered from high power to low power
        end do
        gamnew = gam
        do n = 0,20
            gamnew(n,0:n) = gamnew(n,0:n) * zminzbar(20-n:20)
        end do
        
        alpha(0:40) = 0.d0
        beta(0:40) = 0.d0
        alpha(0) = a(0)
        beta(0) = b(0)
        do n = 1,20
            alpha(n:2*n) = alpha(n:2*n) + a(n) * gamnew(n,0:n)
            beta(n:2*n)  = beta(n:2*n)  + b(n) * gamnew(n,0:n)
        end do
        
        omega = 0.d0
        d1minzeta = -1.d0/biglab - zeta
        d2minzeta = 1.d0/biglab - zeta
        log1 = cdlog(d1minzeta)
        log2 = cdlog(d2minzeta)
        term1 = 1.d0
        term2 = 1.d0
        ! I tried to serialize this, but it didn't speed things up
        do n = 0,40
            term1 = term1 * d1minzeta
            term2 = term2 * d2minzeta
            omega = omega + ( 2.d0 * alpha(n) * log2 - 2.d0 * alpha(n) / (n+1) + beta(n) ) * term2 / (n+1)
            omega = omega - ( 2.d0 * alpha(n) * log1 - 2.d0 * alpha(n) / (n+1) + beta(n) ) * term1 / (n+1)
        end do

        phi = -biga / (2.d0*pi) * real(omega)

        return
    end function bessellsreal
    
    function bessells_int(x,y,z1,z2,lab) result(omega)
        implicit none
        real(kind=8), intent(in) :: x,y
        complex(kind=8), intent(in) :: z1,z2,lab
        real(kind=8) :: biglab, biga, L, ang, tol
        complex(kind=8) :: zeta, zetabar, omega, log1, log2, term1, term2, d1minzeta, d2minzeta
        complex(kind=8), dimension(0:20) :: zminzbar, anew, bnew, exprange
        complex(kind=8), dimension(0:20,0:20) :: gamnew, gam2
        complex(kind=8), dimension(0:40) :: alpha, beta, alpha2
        integer :: n
                
        L = abs(z2-z1)
        biga = abs(lab)
        ang = atan2(aimag(lab),real(lab))
        biglab = 2.d0 * biga / L
        
        tol = 1.d-12
        
        exprange = exp(-cmplx(0,2,kind=8) * ang * nrange )
        anew = a * exprange
        bnew = (b - a * cmplx(0,2,kind=8) * ang) * exprange

        zeta = (2.d0 * dcmplx(x,y) - (z1+z2) ) / (z2-z1) / biglab 
        zetabar = conjg(zeta)
        !do n = 0,20
        !    zminzbar(n) = (zeta-zetabar)**(20-n)  ! Ordered from high power to low power
        !end do
        zminzbar(20) = 1.d0
        do n = 1,20
            zminzbar(20-n) = zminzbar(21-n) * (zeta-zetabar)  ! Ordered from high power to low power
        end do
        gamnew = gam
        do n = 0,20
            gamnew(n,0:n) = gamnew(n,0:n) * zminzbar(20-n:20)
            gam2(n,0:n) = conjg(gamnew(n,0:n))
        end do
        
        alpha(0:40) = 0.d0
        beta(0:40) = 0.d0
        alpha2(0:40) = 0.d0
        alpha(0) = anew(0)
        beta(0) = bnew(0)
        alpha2(0) = anew(0)
        do n = 1,20
            alpha(n:2*n) = alpha(n:2*n) + anew(n) * gamnew(n,0:n)
            beta(n:2*n)  = beta(n:2*n)  + bnew(n) * gamnew(n,0:n)
            alpha2(n:2*n) = alpha2(n:2*n) + anew(n) * gam2(n,0:n)
        end do
        
        omega = 0.d0
        d1minzeta = -1.d0/biglab - zeta
        d2minzeta = 1.d0/biglab - zeta
        if (abs(d1minzeta) < tol) d1minzeta = d1minzeta + cmplx(tol,0.d0,kind=8)
        if (abs(d2minzeta) < tol) d2minzeta = d2minzeta + cmplx(tol,0.d0,kind=8)
        log1 = log(d1minzeta)
        log2 = log(d2minzeta)
        term1 = 1.d0
        term2 = 1.d0
        ! I tried to serialize this, but it didn't speed things up
        do n = 0,40
            term1 = term1 * d1minzeta
            term2 = term2 * d2minzeta
            omega = omega + ( alpha(n) * log2 - alpha(n) / (n+1) + beta(n) ) * term2 / (n+1)
            omega = omega - ( alpha(n) * log1 - alpha(n) / (n+1) + beta(n) ) * term1 / (n+1)
            omega = omega + ( alpha2(n) * conjg(log2) - alpha2(n) / (n+1) ) * conjg(term2) / (n+1)
            omega = omega - ( alpha2(n) * conjg(log1) - alpha2(n) / (n+1) ) * conjg(term1) / (n+1)
        end do

        omega = -biga / (2.d0*pi) * omega

        return
    end function bessells_int
    
    function bessells_gauss(x,y,z1,z2,lab) result(omega)
        implicit none
        real(kind=8), intent(in) :: x,y
        complex(kind=8), intent(in) :: z1,z2
        complex(kind=8), intent(in) :: lab
        complex(kind=8) :: omega
        integer :: n
        real(kind=8) :: L, x0
        complex(kind=8) :: bigz, biglab
        
        L = abs(z2-z1)
        biglab = 2.d0 * lab / L
        bigz = (2.d0 * cmplx(x,y,kind=8) - (z1+z2) ) / (z2-z1)
        omega = cmplx(0.d0,0.d0,kind=8)
        do n = 1,8
            x0 = real(bigz) - xg(n)
            omega = omega + wg(n) * besselk0( x0, aimag(bigz), biglab )
        end do
        omega = -L/(4.d0*pi) * omega
        return
    end function bessells_gauss
    
    function bessells(x,y,z1,z2,lab) result(omega)
        implicit none
        real(kind=8), intent(in) :: x,y
        complex(kind=8), intent(in) :: z1,z2
        complex(kind=8), intent(in) :: lab
        complex(kind=8) :: omega
        
        integer :: Nls, n
        real(kind=8) :: Lnear, L
        complex(kind=8) :: z, delz, za, zb
        
        Lnear = 3.d0
        z = cmplx(x,y,kind=8)
        omega = cmplx(0.d0,0.d0,kind=8)
        L = abs(z2-z1)
        if ( L < Lnear*abs(lab) ) then  ! No need to break integral up
            if ( abs( z - 0.5d0*(z1+z2) ) < 0.5d0 * Lnear * L ) then  ! Do integration
                omega = bessells_int(x,y,z1,z2,lab)
            else
                omega = bessells_gauss(x,y,z1,z2,lab)
            end if
        else  ! Break integral up in parts
            Nls = ceiling( L / (Lnear*abs(lab)) )
            delz = (z2-z1)/Nls
            L = abs(delz)
            do n = 1,Nls
                za = z1 + (n-1) * delz
                zb = z1 + n * delz
                if ( abs( z - 0.5d0*(za+zb) ) < 0.5d0 * Lnear * L ) then  ! Do integration
                    omega = omega + bessells_int(x,y,za,zb,lab)
                else
                    omega = omega + bessells_gauss(x,y,za,zb,lab)
                end if
            end do
        end if
        return
    end function bessells
    
    subroutine bessellsv(x,y,z1,z2,lab,nlab,omega)
        implicit none
        real(kind=8), intent(in) :: x,y
        complex(kind=8), intent(in) :: z1,z2
        integer, intent(in) :: nlab
        complex(kind=8), dimension(nlab), intent(in) :: lab
        complex(kind=8), dimension(nlab), intent(inout) :: omega
        integer :: n
        do n = 1,nlab
            omega(n) = bessells(x,y,z1,z2,lab(n))
        end do
    end subroutine bessellsv
    
    function bessells_circcheck(x,y,z1in,z2in,lab) result(omega)
        implicit none
        real(kind=8), intent(in) :: x,y
        complex(kind=8), intent(in) :: z1in,z2in
        complex(kind=8), intent(in) :: lab
        complex(kind=8) :: omega
        
        integer :: Npt, Nls, n
        real(kind=8) :: Lnear, Lzero, L, x1, y1, x2, y2
        complex(kind=8) :: z, z1, z2, delz, za, zb
        
        Lnear = 3.d0
        Lzero = 20.d0
        z = cmplx(x,y,kind=8)
        call circle_line_intersection( z1in, z2in, z, Lzero*abs(lab), x1, y1, x2, y2, Npt )
        
        z1 = cmplx(x1,y1,kind=8); z2 = cmplx(x2,y2,kind=8) ! f2py has problems with subroutines returning complex variables
        
        omega = cmplx(0.d0,0.d0,kind=8)
        
        if (Npt==2) then
    
            L = abs(z2-z1)
            if ( L < Lnear*abs(lab) ) then  ! No need to break integral up
                if ( abs( z - 0.5d0*(z1+z2) ) < 0.5d0 * Lnear * L ) then  ! Do integration
                    omega = bessells_int(x,y,z1,z2,lab)
                else
                    omega = bessells_gauss(x,y,z1,z2,lab)
                end if
            else  ! Break integral up in parts
                Nls = ceiling( L / (Lnear*abs(lab)) )
                delz = (z2-z1)/Nls
                L = abs(delz)
                do n = 1,Nls
                    za = z1 + (n-1) * delz
                    zb = z1 + n * delz
                    if ( abs( z - 0.5d0*(za+zb) ) < 0.5d0 * Lnear * L ) then  ! Do integration
                        print *,'bessells_int ',bessells_int(x,y,za,zb,lab)
                        omega = omega + bessells_int(x,y,za,zb,lab)
                    else
                        omega = omega + bessells_gauss(x,y,za,zb,lab)
                    end if
                end do
            end if
        end if
        return
    end function bessells_circcheck
    
    subroutine circle_line_intersection( z1, z2, zc, R, xouta, youta, xoutb, youtb, N ) 
        implicit none
        complex(kind=8), intent(in) :: z1, z2, zc
        real(kind=8), intent(in) :: R
        real(kind=8), intent(inout) :: xouta, youta, xoutb, youtb
        integer, intent(inout) :: N
        real(kind=8) :: Lover2, d, xa, xb
        complex(kind=8) :: bigz, za, zb
        
        N = 0
        za = cmplx(0.d0,0.d0,kind=8)
        zb = cmplx(0.d0,0.d0,kind=8)
        
        Lover2 = abs(z2-z1) / 2.d0
        bigz = (2*zc - (z1+z2)) * Lover2 / (z2-z1)
        
        if (abs(aimag(bigz)) < R) then
            d = sqrt( R**2 - aimag(bigz)**2 )
            xa = real(bigz) - d
            xb = real(bigz) + d
            if (( xa < Lover2 ) .and. ( xb > -Lover2 )) then
                N = 2
                if (xa < -Lover2) then
                    za = z1
                else
                    za = ( xa * (z2-z1) / Lover2 + (z1+z2) ) / 2.d0
                end if
                if (xb > Lover2) then
                    zb = z2
                else
                    zb = ( xb * (z2-z1) / Lover2 + (z1+z2) ) / 2.d0
                end if
            end if
        end if
        
        xouta = real(za); youta = aimag(za)
        xoutb = real(zb); youtb = aimag(zb)
        
        return
    end subroutine circle_line_intersection
    
    function testls(x,y,z1in,z2in,lab,nlab) result(omega)
        implicit none
        real(kind=8), intent(in) :: x,y
        complex(kind=8), intent(in) :: z1in,z2in
        integer, intent(in) :: nlab
        complex(kind=8), dimension(nlab), intent(in) :: lab
        complex(kind=8), dimension(nlab) :: omega
        integer :: n
        do n = 1,nlab
            omega(n) = bessells(x,y,z1in,z2in,lab(n))
        end do
    end function testls
    
    subroutine testls2(x,y,z1in,z2in,lab,nlab,omega) 
        implicit none
        real(kind=8), intent(in) :: x,y
        complex(kind=8), intent(in) :: z1in,z2in
        integer, intent(in) :: nlab
        complex(kind=8), dimension(nlab), intent(in) :: lab
        complex(kind=8), dimension(nlab), intent(inout) :: omega
        integer :: n
        do n = 1,nlab
            omega(n) = bessells(x,y,z1in,z2in,lab(n))
        end do
    end subroutine testls2
    
    subroutine testk(x,y,lab,nlab,omega) 
        implicit none
        real(kind=8), intent(in) :: x,y
        integer, intent(in) :: nlab
        complex(kind=8), dimension(nlab), intent(in) :: lab
        complex(kind=8), dimension(nlab), intent(inout) :: omega
        integer :: n
        complex(kind=8) :: z
        do n = 1,nlab
            z = sqrt(x**2 + y**2) / lab(n)
            omega(n) = besselcheb(z,10)
        end do
    end subroutine testk
    
    subroutine test3(nlab,omega)
        implicit none
        integer, intent(in) :: nlab
        complex(kind=8), dimension(nlab), intent(inout) :: omega
        integer :: n
        do n = 1,nlab
            omega(n) = cmplx(1,1,kind=8)
        end do
    end subroutine test3
    
    subroutine test4(M)
        implicit none
        integer, intent(in) :: M
        complex(kind=8), dimension(M,M) :: f
        print *,f
    end subroutine test4
    
!!!!!!!!!!!! THIS ONE WORKS    
    function bessellsOK(x, y) result(phi)
        implicit none
        real(kind=8), intent(in) :: x,y
        real(kind=8) :: phi
        complex(kind=8) :: zeta, zetabar, omega, log1, log2, term1, term2, d1minzeta, d2minzeta
        complex(kind=8), dimension(0:20) :: zminzbar
        complex(kind=8), dimension(0:20,0:20) :: gamnew
        complex(kind=8), dimension(0:40) :: alpha, beta

        integer :: n
        
        zeta = cmplx(x,y)
        zetabar = conjg(zeta)
        do n = 0,20
            zminzbar(n) = (zeta-zetabar)**(20-n)  ! Ordered from high power to low power
        end do
        gamnew = gam
        do n = 0,20
            gamnew(n,0:n) = gamnew(n,0:n) * zminzbar(20-n:20)
        end do
        
        alpha(0:40) = 0.d0
        beta(0:40) = 0.d0
        alpha(0) = a(0)
        beta(0) = b(0)
        do n = 1,20
            alpha(n:2*n) = alpha(n:2*n) + a(n) * gamnew(n,0:n)
            beta(n:2*n)  = beta(n:2*n)  + b(n) * gamnew(n,0:n)
        end do
        
        omega = 0.d0
        d1minzeta = -1.d0 - zeta
        d2minzeta = 1.d0 - zeta
        log1 = log(d1minzeta)
        log2 = log(d2minzeta)
        term1 = 1.d0
        term2 = 1.d0
        ! I tried to serialize this, but it didn't speed things up
        do n = 0,40
            term1 = term1 * d1minzeta
            term2 = term2 * d2minzeta
            omega = omega + ( 2.d0 * alpha(n) * log2 - 2.d0 * alpha(n) / (n+1) + beta(n) ) * term2 / (n+1)
            omega = omega - ( 2.d0 * alpha(n) * log1 - 2.d0 * alpha(n) / (n+1) + beta(n) ) * term1 / (n+1)
        end do

        phi = -1.d0 / (2.d0*pi) * real(omega)

        return
    end function bessellsOK
!!!!!!!!!!!!!!!!! THIS ONE WORKS
!    
!    function bessells2(x, y) result(phi)
!        implicit none
!        real(kind=8), intent(in) :: x,y
!        real(kind=8) :: phi
!        complex(kind=8) :: zeta, omega, log1, log2, d1minzeta, d2minzeta
!        complex(kind=8), dimension(0:20) :: zminzbar
!        complex(kind=8), dimension(0:20,0:20) :: gamnew
!        complex(kind=8), dimension(0:40) :: alpha, beta, term1, term2
!    
!        integer :: n
!        
!        zeta = cmplx(x,y)
!        !zminzbar = (zeta - conjg(zeta))**nback
!        do n = 0,20
!            zminzbar(n) = (zeta-conjg(zeta))**(20-n)  ! Ordered from high power to low power
!        end do
!        gamnew = gam
!        do n = 0,20
!            gamnew(n,0:n) = gamnew(n,0:n) * zminzbar(20-n:20)
!        end do
!        
!        alpha(0:40) = 0.d0
!        beta(0:40) = 0.d0
!        alpha(0) = a(0)
!        beta(0) = b(0)
!        do n = 1,20
!            alpha(n:2*n) = alpha(n:2*n) + a(n) * gamnew(n,0:n)
!            beta(n:2*n)  = beta(n:2*n)  + b(n) * gamnew(n,0:n)
!        end do
!        
!        !omega = 0.d0
!        !d1minzeta = -1.d0 - zeta
!        !d2minzeta = 1.d0 - zeta
!        !log1 = log(d1minzeta)
!        !log2 = log(d2minzeta)
!        !term1 = 1.d0
!        !term2 = 1.d0
!        !! This can easily be serialized
!        !do n = 0,40
!        !    term1 = term1 * d1minzeta
!        !    term2 = term2 * d2minzeta
!        !    omega = omega + ( 2.d0 * alpha(n) * log2 - 2.d0 * alpha(n) / (n+1) + beta(n) ) * term2 / (n+1)
!        !    omega = omega - ( 2.d0 * alpha(n) * log1 - 2.d0 * alpha(n) / (n+1) + beta(n) ) * term1 / (n+1)
!        !end do
!        
!        d1minzeta = -1.d0 - zeta
!        d2minzeta = 1.d0 - zeta
!        log1 = log(d1minzeta)
!        log2 = log(d2minzeta)
!        term1(0) = d1minzeta
!        term2(0) = d2minzeta
!        do n = 1,40
!            term1(n) = term1(n-1) * d1minzeta
!            term2(n) = term2(n-1) * d2minzeta
!        end do
!        !term1 = d1minzeta**nlongp
!        !term2 = d2minzeta**nlongp
!        omega = sum( ( 2.d0 * alpha * log2 - 2.d0 * alpha / nlongp + beta ) * term2 / nlongp -  &
!                     ( 2.d0 * alpha * log1 - 2.d0 * alpha / nlongp + beta ) * term1 / nlongp )
!        phi = -1.d0 / (2.d0*pi) * real(omega)
!    
!        return
!    end function bessells2

end module bessel

program besseltest
    use bessel

    complex(kind=8) :: omega,omega1,omega2, z, lab
    call initialize
    !z = 5.d0 / cmplx(1,1,8)
    !omega = besselk0near(z,10)
    !print *,'omega near ',omega, besselk0( 3.d0, 4.d0, cmplx(1,1,kind=8))
    !omega = besselk0far(z,10)
    !print *,'omega far ',omega, besselk0( 3.d0, 4.d0, cmplx(1,1,kind=8))
    !omega = besselcheb(z, 12)
    !print *,'omega cheb ',omega
    !omega = besselk0cheb(z, 12)
    !print *,'omega cheb ',omega
    !za = cmplx(0,0,8); zb = cmplx(0,0,8); N=0
    !call circle_line_intersection(cmplx(-1,-2,kind=8),cmplx(3,1,kind=8),cmplx(-1,0,kind=8),5.d0,za,zb,N)
    !if (N==2) then
    !    print *,'N equals 2!'
    !end if
    !print *,'za,zb,N ',za,zb,N
    !omega = bessells_gauss(3.d0,0.d0,cmplx(-2.d0,0.d0,8),cmplx(2.d0,0.d0,8),cmplx(0.5d0,0.5d0,8))
    !print *,omega
    !omega = bessells_int(3.d0,0.d0,cmplx(-2.d0,0.d0,8),cmplx(2.d0,0.d0,8),cmplx(0.5d0,0.5d0,8))
    !print *,omega
    !omega = bessells(3.d0,0.d0,cmplx(-2.d0,0.d0,8),cmplx(2.d0,0.d0,8),cmplx(0.5d0,0.5d0,8))
    !print *,omega
    !omega1 = bessells_gauss(0.d0,3.d0,cmplx(-1.d0,0.d0,8),cmplx(1.d0,0.d0,8),cmplx(0.0d0,1.0d0,8))
    !print *,omega1
    !omega2 = bessells_int(0.d0,3.d0,cmplx(-1.d0,0.d0,8),cmplx(1.d0,0.d0,8),cmplx(0.0d0,1.0d0,8))
    !print *,omega2
    !omega = bessells(0.d0,3.d0,cmplx(-1.d0,0.d0,8),cmplx(1.d0,0.d0,8),cmplx(0.0d0,1.0d0,8))
    !print *,omega
    lab = cmplx(0.18993748667372698d0,-0.13389092596486057d0, 8)
    print *,'lab ',lab
    omega1 = bessells_circcheck(0.d0,1.d0,cmplx(-10.d0,0.d0,8),cmplx(0.d0,0.d0,8),lab)
    print *,'omega1 ',omega1
    omega2 = bessells_circcheck(0.d0,1.d0,cmplx(0.d0,0.d0,8),cmplx(10.d0,0.d0,8),lab)
    print *,'omega2 ',omega2
    print *,'omega+ ',omega1+omega2
    omega = bessells_circcheck(0.d0,1.d0,cmplx(-10.d0,0.d0,8),cmplx(10.d0,0.d0,8),lab)
    print *,'omega  ',omega

    

    !lab2(1) = cmplx(0.5d0,0.5d0,8)
    !lab2(2) = cmplx(0.5d0,1.5d0,8)
    !lab2(3) = cmplx(0.5d0,2.5d0,8)
    !omega2 = testls(0.d0,3.d0,cmplx(-1.d0,0.d0,8),cmplx(1.d0,0.d0,8),lab2,3)
    !print *,omega2
    !call testls2(0.d0,3.d0,cmplx(-1.d0,0.d0,8),cmplx(1.d0,0.d0,8),lab2,3,omega2)
    !print *,omega2
    !call test3(3,omega2)
    !print *,omega2
end