#!/bin/bash
#set -x

echo
MODULES_DIR="/lib/modules/"
for i in $(find ${MODULES_DIR} -maxdepth 1 -type d|grep -vw "${MODULES_DIR}"|sed s,'/lib/modules/',,g);do
	KERNEL_DIR="/usr/src/linux-${i}"
	echo -e "Assinando módulo para kernel ${i}..."
	for z in $(find /lib/modules/${i} -type f -iname "*vbox*.ko");do
		#perl ${KERNEL_DIR}/scripts/sign-file sha512 ${KERNEL_DIR}/certs/signing_key.priv ${KERNEL_DIR}/certs/signing_key.x509 ${z}
		${KERNEL_DIR}/scripts/sign-file sha512 ${KERNEL_DIR}/certs/signing_key.pem ${KERNEL_DIR}/certs/signing_key.x509 ${z}
	done
done
echo -e "done.\n"
