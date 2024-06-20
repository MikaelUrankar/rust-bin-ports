PORTNAME=	rust
DISTVERSION=	1.79.0
CATEGORIES=	lang
MASTER_SITES=	LOCAL/mikael/rust-bin
PKGNAMESUFFIX=	-bin
DISTFILES=	rustc-${DISTVERSION}-${_RUST_TARGET}${EXTRACT_SUFX} \
		rust-std-${DISTVERSION}-${_RUST_TARGET}${EXTRACT_SUFX} \
		cargo-${DISTVERSION}-${_RUST_TARGET}${EXTRACT_SUFX} \
		rust-std-${DISTVERSION}-wasm32-unknown-unknown${EXTRACT_SUFX}
DIST_SUBDIR=	rust/rust-bin/${DISTVERSION}

MAINTAINER=	mikael@FreeBSD.org
COMMENT=	Prebuilt rust toolchain
WWW=		https://www.rust-lang.org/

LICENSE=	APACHE20 MIT
LICENSE_COMB=	dual

ONLY_FOR_ARCHS=	aarch64 amd64 armv7 i386 powerpc powerpc64 powerpc64le riscv64

USES=		cpe tar:xz

CPE_VENDOR=	rust-lang

CONFLICTS_INSTALL?=	rust rust-nightly

NO_BUILD=	yes

# Rust's target arch string might be different from *BSD arch strings
_RUST_ARCH_amd64=	x86_64
_RUST_ARCH_i386=	i686
_RUST_ARCH_riscv64=	riscv64gc
_RUST_TARGET=		${_RUST_ARCH_${ARCH}:U${ARCH}}-unknown-freebsd

.include <bsd.port.pre.mk>

.if make(makesum)
DISTFILES:=	${DISTFILES:M*\:src} \
		${ONLY_FOR_ARCHS:O:@_arch@${:!${MAKE} ARCH=${_arch} -V'DISTFILES:N*\:src'!}@}
.endif

do-install:
	${MKDIR} ${WRKDIR}/rust

.for _c in rustc-${DISTVERSION}-${_RUST_TARGET} \
	   rust-std-${DISTVERSION}-${_RUST_TARGET} \
	   cargo-${DISTVERSION}-${_RUST_TARGET} \
	   rust-std-${DISTVERSION}-wasm32-unknown-unknown
	cd ${WRKDIR}/${_c} && \
		${SH} install.sh \
		--docdir="${STAGEDIR}${DOCSDIR}" \
		--mandir="${STAGEDIR}${PREFIX}/share/man" \
		--prefix="${STAGEDIR}${PREFIX}"
.endfor

# do some cleanup
	@${RM}	${STAGEDIR}${DOCSDIR}/*.old \
		${STAGEDIR}${PREFIX}/lib/rustlib/components \
		${STAGEDIR}${PREFIX}/lib/rustlib/install.log \
		${STAGEDIR}${PREFIX}/lib/rustlib/manifest-* \
		${STAGEDIR}${PREFIX}/lib/rustlib/rust-installer-version \
		${STAGEDIR}${PREFIX}/lib/rustlib/uninstall.sh
	@${FIND} ${STAGEDIR}${PREFIX}/bin ${STAGEDIR}${PREFIX}/lib \
		${STAGEDIR}${PREFIX}/libexec -exec ${FILE} -i {} + | \
		${AWK} -F: '/executable|sharedlib/ { print $$1 }' | ${XARGS} ${STRIP_CMD}

# We autogenerate the plist file.  We do that, instead of the
# regular pkg-plist, because several libraries have a computed
# filename based on the absolute path of the source files.  As it
# is user-specific, we cannot know their filename in advance.
	@${RM}	${STAGEDIR}${DOCSDIR}/*.old \
		${STAGEDIR}${PREFIX}/lib/rustlib/components \
		${STAGEDIR}${PREFIX}/lib/rustlib/install.log \
		${STAGEDIR}${PREFIX}/lib/rustlib/manifest-* \
		${STAGEDIR}${PREFIX}/lib/rustlib/rust-installer-version \
		${STAGEDIR}${PREFIX}/lib/rustlib/uninstall.sh
	@${FIND} ${STAGEDIR}${PREFIX}/bin ${STAGEDIR}${PREFIX}/lib \
		${STAGEDIR}${PREFIX}/libexec -exec ${FILE} -i {} + | \
		${AWK} -F: '/executable|sharedlib/ { print $$1 }' | ${XARGS} ${STRIP_CMD}
	@${FIND} ${STAGEDIR}${PREFIX} -not -type d | \
		${SED} -E -e 's,^${STAGEDIR}${PREFIX}/,,' \
			-e 's,(share/man/man[1-9]/.*\.[0-9]),\1.gz,' >> ${TMPPLIST}

.include <bsd.port.post.mk>
