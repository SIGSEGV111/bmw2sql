.PHONY: all clean install rpm doc deploy rpm-install

ifeq ($(VERSION),)
	VERSION = *DEVELOPMENT SNAPSHOT*
endif

ARCH = noarch
BINDIR ?= /usr/bin
MANDIR ?= /usr/share/man
KEYID ?= BE5096C665CA4595AF11DAB010CD9FF74E4565ED
ARCH_RPM_NAME := bmw2sql.$(ARCH).rpm

all: bmw2sql.sh

doc: bmw2sql.1

rpm: $(ARCH_RPM_NAME)

rpm-install: rpm
	zypper in "./$(ARCH_RPM_NAME)"

clean:
	rm -vf -- bmw2sql.1 *.rpm

bmw2sql.1: README.md Makefile
	go-md2man < README.md > bmw2sql.1

install: bmw2sql.1 bmw2sql.sh Makefile
	mkdir -p "$(BINDIR)" "$(MANDIR)/man1"
	install -m 755 bmw2sql.sh "$(BINDIR)/"
	install -m 644 bmw2sql.1 "$(MANDIR)/man1/"

deploy: $(ARCH_RPM_NAME)
	ensure-git-clean.sh
	deploy-rpm.sh --infile=bmw2sql.src.rpm --outdir="$(RPMDIR)" --keyid="$(KEYID)" --srpm
	deploy-rpm.sh --infile="$(ARCH_RPM_NAME)" --outdir="$(RPMDIR)" --keyid="$(KEYID)"

$(ARCH_RPM_NAME) bmw2sql.src.rpm: Makefile bmw2sql.spec README.md LICENSE.md bmw2sql.sh
	easy-rpm.sh --name bmw2sql --outdir . --plain --arch "$(ARCH)" -- $^
