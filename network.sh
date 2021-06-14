DIR="$( cd "$( dirname "$0" )" && pwd )"
CDIR=$DIR/config
BDIR=$DIR/build
ADIR=$BDIR/artifacts
ACDIR=$ADIR/crypto-config
CADIR=$ACDIR/fabric-ca
TDIR=$ADIR/tx
BLKDIR=$ADIR/block
ORDIR=$ACDIR/ordererOrganizations

COMPOSE_FILE_PEER=docker-compose/docker-compose-peer.yaml
COMPOSE_FILE_ORDERER=docker-compose/docker-compose-orderer.yaml
COMPOSE_FILE_COUCH=docker-compose/docker-compose-couch.yaml
COMPOSE_FILE_CLI=docker-compose/docker-compose-cli.yaml
COMPOSE_FILE_CA=docker-compose/docker-compose-ca.yaml
IMAGETAG="2.2"
CA_IMAGETAG="1.4.9"
usermod -aG docker $USER


# function enrollOrgCA {
#     org=${1:-blockchain}

#     echo "Enroll the CA admin"
#     mkdir -p $ACDIR/peerOrganizations/${org}.islab.re.kr/

#     export FABRIC_CA_CLIENT_HOME=$ACDIR/peerOrganizations/${org}.islab.re.kr/

#     docker exec -i -t ${org}.islab.re.kr \
#         fabric-ca-client enroll \
#             -u https://admin:adminpw@localhost:7054 \
#             --caname ${org}.islab.re.kr \
#             --tls.certfiles /etc/hyperledger/fabric-ca-server/tls-cert.pem

#     mv $ACDIR/peerOrganizations/${org}.islab.re.kr/msp/cacerts/localhost-7054-${org}-islab-re-kr.pem $ACDIR/peerOrganizations/${org}.islab.re.kr/msp/cacerts/localhost-7054-${org}.islab.re.kr.pem

#     echo "NodeOUs:
#     Enable: true
#     ClientOUIdentifier:
#         Certificate: cacerts/localhost-7054-${org}.islab.re.kr.pem
#         OrganizationalUnitIdentifier: client
#     PeerOUIdentifier:
#         Certificate: cacerts/localhost-7054-${org}.islab.re.kr.pem
#         OrganizationalUnitIdentifier: peer
#     AdminOUIdentifier:
#         Certificate: cacerts/localhost-7054-${org}.islab.re.kr.pem
#         OrganizationalUnitIdentifier: admin
#     OrdererOUIdentifier:
#         Certificate: cacerts/localhost-7054-${org}.islab.re.kr.pem
#         OrganizationalUnitIdentifier: orderer" > config.yaml

#     mv ./config.yaml $ACDIR/peerOrganizations/${org}.islab.re.kr/msp/

#     echo "Register peer0"
#     docker exec -i -t ${org}.islab.re.kr \
#         fabric-ca-client register \
#             --caname ${org}.islab.re.kr \
#             --id.name peer0 \
#             --id.secret peer0pw \
#             --id.type peer \
#             --tls.certfiles /etc/hyperledger/fabric-ca-server/tls-cert.pem

#     echo "Register user"
#     docker exec -i -t ${org}.islab.re.kr \
#         fabric-ca-client register \
#             --caname ${org}.islab.re.kr \
#             --id.name user1 \
#             --id.secret user1pw \
#             --id.type client \
#             --tls.certfiles /etc/hyperledger/fabric-ca-server/tls-cert.pem

#     echo "Register the org admin"
#     docker exec -i -t ${org}.islab.re.kr \
#         fabric-ca-client register \
#             --caname ${org}.islab.re.kr \
#             --id.name ${org}admin \
#             --id.secret ${org}adminpw \
#             --id.type admin \
#             --tls.certfiles /etc/hyperledger/fabric-ca-server/tls-cert.pem

#     echo "## Generate the peer0 msp"
#     docker exec -i -t ${org}.islab.re.kr \
#         fabric-ca-client enroll \
#             -u https://peer0:peer0pw@localhost:7054 \
#             --caname ${org}.islab.re.kr \
#             -M /etc/hypereledger/fabric/msp \
#             --csr.hosts peer0.${org}.islab.re.kr \
#             --tls.certfiles /etc/hyperledger/fabric-ca-server/tls-cert.pem

#     cp $ACDIR/peerOrganizations/${org}.islab.re.kr/msp/config.yaml $ACDIR/peerOrganizations/${org}.islab.re.kr/peers/peer0.${org}.islab.re.kr/msp/config.yaml

#     echo "## Generate the peer0-tls certificates"
#     docker exec -i -t ${org}.islab.re.kr \
#         fabric-ca-client enroll \
#             -u https://peer0:peer0pw@localhost:7054 \
#             --caname ${org}.islab.re.kr \
#             -M /etc/hypereledger/fabric/tls \
#             --enrollment.profile tls \
#             --csr.hosts peer0.${org}.islab.re.kr \
#             --tls.certfiles /etc/hyperledger/fabric-ca-server/tls-cert.pem


#     cp $ACDIR/peerOrganizations/${org}.islab.re.kr/peers/peer0.${org}.islab.re.kr/tls/tlscacerts/* $ACDIR/peerOrganizations/${org}.islab.re.kr/peers/peer0.${org}.islab.re.kr/tls/ca.crt
#     cp $ACDIR/peerOrganizations/${org}.islab.re.kr/peers/peer0.${org}.islab.re.kr/tls/signcerts/* $ACDIR/peerOrganizations/${org}.islab.re.kr/peers/peer0.${org}.islab.re.kr/tls/server.crt
#     cp $ACDIR/peerOrganizations/${org}.islab.re.kr/peers/peer0.${org}.islab.re.kr/tls/keystore/* $ACDIR/peerOrganizations/${org}.islab.re.kr/peers/peer0.${org}.islab.re.kr/tls/server.key

#     mkdir -p $ACDIR/peerOrganizations/${org}.islab.re.kr/msp/tlscacerts
#     cp $ACDIR/peerOrganizations/${org}.islab.re.kr/peers/peer0.${org}.islab.re.kr/tls/tlscacerts/* $ACDIR/peerOrganizations/${org}.islab.re.kr/msp/tlscacerts/ca.crt

#     mkdir -p $ACDIR/peerOrganizations/${org}.islab.re.kr/tlsca
#     cp $ACDIR/peerOrganizations/${org}.islab.re.kr/peers/peer0.${org}.islab.re.kr/tls/tlscacerts/* $ACDIR/peerOrganizations/${org}.islab.re.kr/tlsca/tlsca.${org}.islab.re.kr-cert.pem

#     mkdir -p $ACDIR/peerOrganizations/${org}.islab.re.kr/ca
#     cp $ACDIR/peerOrganizations/${org}.islab.re.kr/peers/peer0.${org}.islab.re.kr/msp/cacerts/* $ACDIR/peerOrganizations/${org}.islab.re.kr/ca/ca.${org}.islab.re.kr-cert.pem


#     mkdir -p $ACDIR/peerOrganizations/${org}.islab.re.kr/users/User1@${org}.islab.re.kr/msp


#     echo "## Generate the user msp"

#     docker exec -i -t ${org}.islab.re.kr \
#         fabric-ca-client enroll \
#             -u https://user1:user1pw@localhost:7054 \
#             --caname ${org}.islab.re.kr \
#             -M /etc/hyperledger/fabric-ca-server/users/User1@${org}.islab.re.kr/msp \
#             --tls.certfiles /etc/hyperledger/fabric-ca-server/tls-cert.pem

#     mv $ACDIR/peerOrganizations/${org}.islab.re.kr/users/User1@${org}.islab.re.kr/msp/cacerts/localhost-7054-${org}-islab-re-kr.pem $ACDIR/peerOrganizations/${org}.islab.re.kr/users/User1@${org}.islab.re.kr/msp/cacerts/localhost-7054-${org}.islab.re.kr.pem

#     cp $ACDIR/peerOrganizations/${org}.islab.re.kr/msp/config.yaml $ACDIR/peerOrganizations/${org}.islab.re.kr/users/User1@${org}.islab.re.kr/msp/config.yaml

#     mkdir -p $ACDOR/peerOrganizations/${org}.islab.re.kr/users/Admin@${org}.islab.re.kr/msp

#     echo "## Generate the org admin msp"

#     docker exec -i -t ${org}.islab.re.kr \
#         fabric-ca-client enroll \
#             -u https://${org}admin:${org}adminpw@localhost:7054 \
#             --caname ${org}.islab.re.kr \
#             -M /etc/hyperledger/fabric-ca-server/users/Admin@${org}.islab.re.kr/msp \
#             --tls.certfiles /etc/hyperledger/fabric-ca-server/tls-cert.pem

#     mv $ACDIR/peerOrganizations/${org}.islab.re.kr/users/Admin@${org}.islab.re.kr/msp/cacerts/localhost-7054-${org}-islab-re-kr.pem $ACDIR/peerOrganizations/${org}.islab.re.kr/users/Admin@${org}.islab.re.kr/msp/cacerts/localhost-7054-${org}.islab.re.kr.pem
#     cp $ACDIR/peerOrganizations/${org}.islab.re.kr/msp/config.yaml $ACDIR/peerOrganizations/${org}.islab.re.kr/users/Admin@${org}.islab.re.kr/msp/config.yaml
# }

# function enrollOrdererCA() {
#     echo "Enrolling the CA admin"
#     mkdir -p $ACDIR/ordererOrganizations/islab.re.kr

#     export FABRIC_CA_CLIENT_HOME=$ORDIR/islab.re.kr/

#     docker exec -i -t orderer.islab.re.kr \
#         fabric-ca-client enroll \
#             -u https://admin:adminpw@localhost:8054 \
#             --caname orderer.islab.re.kr \
#             --tls.certfiles /etc/hyperledger/fabric-ca-orderer/tls-cert.pem

#     mv $ACDIR/ordererOrganizations/islab.re.kr/msp/cacerts/localhost-8054-orderer-islab-re-kr.pem $ACDIR/ordererOrganizations/islab.re.kr/msp/cacerts/localhost-8054-orderer.islab.re.kr.pem

#     echo 'NodeOUs:
#     Enable: true
#     ClientOUIdentifier:
#         Certificate: cacerts/localhost-8054-orderer.islab.re.kr.pem
#         OrganizationalUnitIdentifier: client
#     PeerOUIdentifier:
#         Certificate: cacerts/localhost-8054-orderer.islab.re.kr.pem
#         OrganizationalUnitIdentifier: peer
#     AdminOUIdentifier:
#         Certificate: cacerts/localhost-8054-orderer.islab.re.kr.pem
#         OrganizationalUnitIdentifier: admin
#     OrdererOUIdentifier:
#         Certificate: cacerts/localhost-8054-orderer.islab.re.kr.pem
#         OrganizationalUnitIdentifier: orderer' > $ORDIR/islab.re.kr/msp/config.yaml

#     echo "Registering orderer"
#     docker exec -i -t orderer.islab.re.kr \
#         fabric-ca-client register \
#             --caname orderer.islab.re.kr \
#             --id.name orderer \
#             --id.secret ordererpw \
#             --id.type orderer \
#             --tls.certfiles /etc/hyperledger/fabric-ca-orderer/tls-cert.pem

#     echo "Registering the orderer admin"
#     docker exec -i -t orderer.islab.re.kr \
#         fabric-ca-client register \
#             --caname orderer.islab.re.kr \
#             --id.name ordererAdmin \
#             --id.secret ordererAdminpw \
#             --id.type admin \
#             --tls.certfiles /etc/hyperledger/fabric-ca-orderer/tls-cert.pem

#     echo "Generating the orderer0 msp"
#     docker exec -i -t orderer.islab.re.kr \
#         fabric-ca-client enroll \
#             -u https://orderer:ordererpw@localhost:8054 \
#             --caname orderer.islab.re.kr \
#             -M /etc/hyperledger/fabric-ca-orderer/orderers/orderer0.islab.re.kr/msp \
#             --csr.hosts orderer0.islab.re.kr \
#             --csr.hosts localhost \
#             --tls.certfiles /etc/hyperledger/fabric-ca-orderer/tls-cert.pem

#     cp $ORDIR/islab.re.kr/msp/config.yaml $ORDIR/islab.re.kr/orderers/orderer0.islab.re.kr/msp/config.yaml
#     mv $ORDIR/islab.re.kr/orderers/orderer0.islab.re.kr/msp/cacerts/localhost-8054-orderer-islab-re-kr.pem $ORDIR/islab.re.kr/orderers/orderer0.islab.re.kr/msp/cacerts/localhost-8054-orderer.islab.re.kr.pem

#     echo "Generating the orderer0-tls certificates"
#     docker exec -i -t orderer.islab.re.kr \
#         fabric-ca-client enroll \
#             -u https://orderer:ordererpw@localhost:8054 \
#             --caname orderer.islab.re.kr \
#             -M /etc/hyperledger/fabric-ca-orderer/orderers/orderer0.islab.re.kr/tls \
#             --enrollment.profile tls \
#             --csr.hosts orderer0.islab.re.kr \
#             --csr.hosts localhost \
#             --tls.certfiles /etc/hyperledger/fabric-ca-orderer/tls-cert.pem

#     mv $ORDIR/islab.re.kr/orderers/orderer0.islab.re.kr/tls/tlscacerts/tls-localhost-8054-orderer-islab-re-kr.pem $ORDIR/islab.re.kr/orderers/orderer0.islab.re.kr/tls/tlscacerts/tls-localhost-8054-orderer.islab.re.kr.pem

#     cp $ORDIR/islab.re.kr/orderers/orderer0.islab.re.kr/tls/tlscacerts/* $ORDIR/islab.re.kr/orderers/orderer0.islab.re.kr/tls/ca.crt
#     cp $ORDIR/islab.re.kr/orderers/orderer0.islab.re.kr/tls/signcerts/* $ORDIR/islab.re.kr/orderers/orderer0.islab.re.kr/tls/server.crt
#     cp $ORDIR/islab.re.kr/orderers/orderer0.islab.re.kr/tls/keystore/* $ORDIR/islab.re.kr/orderers/orderer0.islab.re.kr/tls/server.key

#     mkdir -p $ORDIR/islab.re.kr/orderers/orderer0.islab.re.kr/msp/tlscacerts
#     cp $ORDIR/islab.re.kr/orderers/orderer0.islab.re.kr/tls/tlscacerts/* $ORDIR/islab.re.kr/orderers/orderer0.islab.re.kr/msp/tlscacerts/tlsca.islab.re.kr-cert.pem # asd

#     mkdir -p $ORDIR/islab.re.kr/msp/tlscacerts
#     cp $ORDIR/islab.re.kr/orderers/orderer0.islab.re.kr/tls/tlscacerts/* $ORDIR/islab.re.kr/msp/tlscacerts/tlsca.islab.re.kr-cert.pem


# echo "Generating the orderer1 msp"
#     docker exec -i -t orderer.islab.re.kr \
#         fabric-ca-client enroll \
#             -u https://orderer:ordererpw@localhost:8054 \
#             --caname orderer.islab.re.kr \
#             -M /etc/hyperledger/fabric-ca-orderer/orderers/orderer1.islab.re.kr/msp \
#             --csr.hosts orderer1.islab.re.kr \
#             --csr.hosts localhost \
#             --tls.certfiles /etc/hyperledger/fabric-ca-orderer/tls-cert.pem

#     cp $ORDIR/islab.re.kr/msp/config.yaml $ORDIR/islab.re.kr/orderers/orderer1.islab.re.kr/msp/config.yaml
#     mv $ORDIR/islab.re.kr/orderers/orderer1.islab.re.kr/msp/cacerts/localhost-8054-orderer-islab-re-kr.pem \
#         $ORDIR/islab.re.kr/orderers/orderer1.islab.re.kr/msp/cacerts/localhost-8054-orderer.islab.re.kr.pem

#     echo "Generating the orderer1-tls certificates"
#     docker exec -i -t orderer.islab.re.kr \
#         fabric-ca-client enroll \
#             -u https://orderer:ordererpw@localhost:8054 \
#             --caname orderer.islab.re.kr \
#             -M /etc/hyperledger/fabric-ca-orderer/orderers/orderer1.islab.re.kr/tls \
#             --enrollment.profile tls \
#             --csr.hosts orderer1.islab.re.kr \
#             --csr.hosts localhost \
#             --tls.certfiles /etc/hyperledger/fabric-ca-orderer/tls-cert.pem

#     mv $ORDIR/islab.re.kr/orderers/orderer1.islab.re.kr/tls/tlscacerts/tls-localhost-8054-orderer-islab-re-kr.pem $ORDIR/islab.re.kr/orderers/orderer1.islab.re.kr/tls/tlscacerts/tls-localhost-8054-orderer.islab.re.kr.pem

#     cp $ORDIR/islab.re.kr/orderers/orderer1.islab.re.kr/tls/tlscacerts/* $ORDIR/islab.re.kr/orderers/orderer1.islab.re.kr/tls/ca.crt
#     cp $ORDIR/islab.re.kr/orderers/orderer1.islab.re.kr/tls/signcerts/* $ORDIR/islab.re.kr/orderers/orderer1.islab.re.kr/tls/server.crt
#     cp $ORDIR/islab.re.kr/orderers/orderer1.islab.re.kr/tls/keystore/* $ORDIR/islab.re.kr/orderers/orderer1.islab.re.kr/tls/server.key

#     mkdir -p $ORDIR/islab.re.kr/orderers/orderer1.islab.re.kr/msp/tlscacerts
#     cp $ORDIR/islab.re.kr/orderers/orderer1.islab.re.kr/tls/tlscacerts/* $ORDIR/islab.re.kr/orderers/orderer1.islab.re.kr/msp/tlscacerts/tlsca.islab.re.kr-cert.pem # asd

#     mkdir -p $ORDIR/islab.re.kr/msp/tlscacerts
#     cp $ORDIR/islab.re.kr/orderers/orderer1.islab.re.kr/tls/tlscacerts/* $ORDIR/islab.re.kr/msp/tlscacerts/tlsca.islab.re.kr-cert.pem

# echo "Generating the orderer2 msp"
#     docker exec -i -t orderer.islab.re.kr \
#         fabric-ca-client enroll \
#             -u https://orderer:ordererpw@localhost:8054 \
#             --caname orderer.islab.re.kr \
#             -M /etc/hyperledger/fabric-ca-orderer/orderers/orderer2.islab.re.kr/msp \
#             --csr.hosts orderer2.islab.re.kr \
#             --csr.hosts localhost \
#             --tls.certfiles /etc/hyperledger/fabric-ca-orderer/tls-cert.pem

#     cp $ORDIR/islab.re.kr/msp/config.yaml $ORDIR/islab.re.kr/orderers/orderer2.islab.re.kr/msp/config.yaml
#     mv $ORDIR/islab.re.kr/orderers/orderer2.islab.re.kr/msp/cacerts/localhost-8054-orderer-islab-re-kr.pem \
#         $ORDIR/islab.re.kr/orderers/orderer2.islab.re.kr/msp/cacerts/localhost-8054-orderer.islab.re.kr.pem

#     echo "Generating the orderer2-tls certificates"
#     docker exec -i -t orderer.islab.re.kr \
#         fabric-ca-client enroll \
#             -u https://orderer:ordererpw@localhost:8054 \
#             --caname orderer.islab.re.kr \
#             -M /etc/hyperledger/fabric-ca-orderer/orderers/orderer2.islab.re.kr/tls \
#             --enrollment.profile tls \
#             --csr.hosts orderer2.islab.re.kr \
#             --csr.hosts localhost \
#             --tls.certfiles /etc/hyperledger/fabric-ca-orderer/tls-cert.pem

#     mv $ORDIR/islab.re.kr/orderers/orderer2.islab.re.kr/tls/tlscacerts/tls-localhost-8054-orderer-islab-re-kr.pem $ORDIR/islab.re.kr/orderers/orderer2.islab.re.kr/tls/tlscacerts/tls-localhost-8054-orderer.islab.re.kr.pem

#     cp $ORDIR/islab.re.kr/orderers/orderer2.islab.re.kr/tls/tlscacerts/* $ORDIR/islab.re.kr/orderers/orderer2.islab.re.kr/tls/ca.crt
#     cp $ORDIR/islab.re.kr/orderers/orderer2.islab.re.kr/tls/signcerts/* $ORDIR/islab.re.kr/orderers/orderer2.islab.re.kr/tls/server.crt
#     cp $ORDIR/islab.re.kr/orderers/orderer2.islab.re.kr/tls/keystore/* $ORDIR/islab.re.kr/orderers/orderer2.islab.re.kr/tls/server.key

#     mkdir -p $ORDIR/islab.re.kr/orderers/orderer2.islab.re.kr/msp/tlscacerts
#     cp $ORDIR/islab.re.kr/orderers/orderer2.islab.re.kr/tls/tlscacerts/* $ORDIR/islab.re.kr/orderers/orderer2.islab.re.kr/msp/tlscacerts/tlsca.islab.re.kr-cert.pem # asd

#     mkdir -p $ORDIR/islab.re.kr/msp/tlscacerts
#     cp $ORDIR/islab.re.kr/orderers/orderer2.islab.re.kr/tls/tlscacerts/* $ORDIR/islab.re.kr/msp/tlscacerts/tlsca.islab.re.kr-cert.pem


#     echo "Generating the admin msp"
#     docker exec -i -t orderer.islab.re.kr \
#         fabric-ca-client enroll \
#             -u https://ordererAdmin:ordererAdminpw@localhost:8054 \
#             --caname orderer.islab.re.kr \
#             -M /etc/hyperledger/fabric-ca-orderer/users/Admin@islab.re.kr/msp \
#             --tls.certfiles /etc/hyperledger/fabric-ca-orderer/tls-cert.pem

#     cp $ORDIR/islab.re.kr/msp/config.yaml $ORDIR/islab.re.kr/users/Admin@islab.re.kr/msp/config.yaml

#     mv $ORDIR/islab.re.kr/users/Admin@islab.re.kr/msp/cacerts/localhost-8054-orderer-islab-re-kr.pem $ORDIR/islab.re.kr/users/Admin@islab.re.kr/msp/cacerts/localhost-8054-orderer.islab.re.kr.pem
# }

function up {
    COMPOSE_FILES="-f ${COMPOSE_FILE_PEER}"
    COMPOSE_FILES="${COMPOSE_FILES} -f ${COMPOSE_FILE_ORDERER}"
    COMPOSE_FILES="${COMPOSE_FILES} -f ${COMPOSE_FILE_COUCH}"
    COMPOSE_FILES="${COMPOSE_FILES} -f ${COMPOSE_FILE_CLI}"
    IMAGE_TAG=$IMAGETAG docker-compose ${COMPOSE_FILES} up -d 2>&1
    docker ps -a
}

function clean {
    down
    rm -Rf $BDIR
    rm -Rf channel-artifacts
    rm -Rf ./chaincode-go/vendor
    rm -Rf ./atcc/vendor
}


function generate {
    CRYPTO=${1:-ca}
    mkdir -p $TDIR 2>&1
    mkdir -p $BLKDIR 2>&1

    if [ "$CRYPTO" = "cryptogen" ]; then
        echo "cryptogen ~~~~~~~~~~~~"
        docker run --rm --name fabric-tools \
            -v $CDIR:/tmp \
            -w /tmp \
            hyperledger/fabric-tools:2.2 \
            cryptogen generate --config=/tmp/crypto-config.yaml \
            --output="crypto-config"

        mv $CDIR/crypto-config $ADIR

    fi

    if [ "$CRYPTO" = "ca" ]; then
        echo "Fabric CA ~~~~~~~~~~~~~~"

        IMAGE_TAG=${CA_IMAGETAG} docker-compose -f $COMPOSE_FILE_CA up -d 2>&1
        enrollOrgCA blockchain
        enrollOrgCA security
        enrollOrgCA ai
        enrollOrdererCA
    fi

    echo "systemchannel"
    docker run --rm --name fabric-tools \
        -v $ADIR/crypto-config:/tmp/crypto-config \
        -v $CDIR:/tmp/config \
        -v $BLKDIR:/tmp/block \
        -w /tmp/block \
        hyperledger/fabric-tools:2.2 \
        configtxgen -configPath /tmp/config \
        -profile SystemChannel -channelID system-channel -outputBlock ./genesis.block

    echo "RegulatoryChannel"
    docker run --rm --name fabric-tools \
        -v $ADIR/crypto-config:/tmp/crypto-config \
        -v $CDIR:/tmp/config \
        -v $TDIR:/tmp/tx \
        -w /tmp/tx \
        hyperledger/fabric-tools:2.2 \
        configtxgen -configPath /tmp/config \
        -profile RegulatoryChannel -channelID regulatory-channel -outputCreateChannelTx ./regulatory-channel.tx

    echo "Userchannel"
    docker run --rm --name fabric-tools \
        -v $ADIR/crypto-config:/tmp/crypto-config \
        -v $CDIR:/tmp/config \
        -v $TDIR:/tmp/tx \
        -w /tmp/tx \
        hyperledger/fabric-tools:2.2 \
        configtxgen -configPath /tmp/config \
        -profile UserChannel -channelID user-channel -outputCreateChannelTx ./user-channel.tx
}

function down {
    COMPOSE_FILES="-f ${COMPOSE_FILE_PEER}"
    COMPOSE_FILES="${COMPOSE_FILES} -f ${COMPOSE_FILE_ORDERER}"
    COMPOSE_FILES="${COMPOSE_FILES} -f ${COMPOSE_FILE_COUCH}"
    COMPOSE_FILES="${COMPOSE_FILES} -f ${COMPOSE_FILE_CLI}"
    COMPOSE_FILES="${COMPOSE_FILES} -f ${COMPOSE_FILE_CA}"
    IMAGE_TAG=$CA_IMAGETAG docker-compose ${COMPOSE_FILES} down -v 2>&1
    IMAGE_TAG=$IMAGETAG docker-compose ${COMPOSE_FILES} down -v 2>&1
    docker volume ls -qf "dangling=true" | xargs docker volume rm
    docker ps -a
}

# function channel_join() {
#     org=${1:-blockchain}
#     channelName=${2:-dev}
#     TLS_PATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/${org}.islab.re.kr/peers/peer0.${org}.islab.re.kr/tls
#     docker exec -i -t \
#         -e CORE_PEER_ID=peer0.${org}.islab.re.kr \
#         -e CORE_PEER_ADDRESS=peer0.${org}.islab.re.kr:7051 \
#         -e CORE_PEER_CHAINCODEADDRESS=peer0.${org}.islab.re.kr:7052 \
#         -e CORE_PEER_GOSSIP_BOOTSTRAP=peer0.${org}.islab.re.kr:7051 \
#         -e CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.${org}.islab.re.kr:7051 \
#         -e CORE_PEER_LOCALMSPID=${org}Org \
#         -e CORE_PEER_TLS_CERT_FILE=$TLS_PATH/server.crt \
#         -e CORE_PEER_TLS_KEY_FILE=$TLS_PATH/server.key \
#         -e CORE_PEER_TLS_ROOTCERT_FILE=$TLS_PATH/ca.crt \
#         -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/${org}.islab.re.kr/users/Admin@${org}.islab.re.kr/msp \
#         -e CORE_PEER_ADDRESS=peer0.${org}.islab.re.kr:7051 \
#         cli peer channel join \
#             -b /opt/gopath/src/github.com/hyperledger/fabric/peer/block/${channelName}-channel.block
# }

function channel_create {
    org=${1:-blockchain}
    channelName=${2:-dev}
    TLS_PATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/${org}.islab.re.kr/peers/peer0.${org}.islab.re.kr/tls
    docker exec -i -t \
        -e CORE_PEER_ID=peer0.${org}.islab.re.kr \
        -e CORE_PEER_ADDRESS=peer0.${org}.islab.re.kr:7051 \
        -e CORE_PEER_CHAINCODEADDRESS=peer0.${org}.islab.re.kr:7052 \
        -e CORE_PEER_GOSSIP_BOOTSTRAP=peer0.${org}.islab.re.kr:7051 \
        -e CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.${org}.islab.re.kr:7051 \
        -e CORE_PEER_LOCALMSPID=${org}Org \
        -e CORE_PEER_TLS_CERT_FILE=$TLS_PATH/server.crt \
        -e CORE_PEER_TLS_KEY_FILE=$TLS_PATH/server.key \
        -e CORE_PEER_TLS_ROOTCERT_FILE=$TLS_PATH/ca.crt \
        -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/${org}.islab.re.kr/users/Admin@${org}.islab.re.kr/msp \
        -e CORE_PEER_ADDRESS=peer0.${org}.islab.re.kr:7051 \
        cli peer channel create \
            -o orderer0.islab.re.kr:7050 \
            -c ${channelName}-channel \
            -f /opt/gopath/src/github.com/hyperledger/fabric/peer/tx/${channelName}-channel.tx \
            --outputBlock /opt/gopath/src/github.com/hyperledger/fabric/peer/block/${channelName}-channel.block \
            --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/islab.re.kr/msp/tlscacerts/tlsca.islab.re.kr-cert.pem
}

# function packageChaincode() {
#     # sample chaincode

#     # docker exec -i -t \
#     #     -w /opt/gopath/src/github.com/asset-transfer-basic/chaincode-go \
#     #     cli go mod vendor

#     # docker exec -i -t \
#     #     cli peer lifecycle chaincode package mychaincode.tar.gz \
#     #         --path /opt/gopath/src/github.com/asset-transfer-basic/chaincode-go \
#     #         --label mychaincode_1.0

#     # my chaincode
#     docker exec -i -t \
#         -w /opt/gopath/src/github.com/mychaincode \
#         cli go mod vendor

#     docker exec -i -t \
#         cli peer lifecycle chaincode package mychaincode.tar.gz \
#             --path /opt/gopath/src/github.com/mychaincode \
#             --label mychaincode_1.0
#     echo "packaging ~~~"
# }

# function allinstallChaincode() {
#     installChaincode blockchain
#     installChaincode ai
#     installChaincode security
# }

# function installChaincode() {
#     org=${1:-blockchain}
#     TLS_PATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/${org}.islab.re.kr/peers/peer0.${org}.islab.re.kr/tls
#     docker exec -i -t \
#         -e CORE_PEER_LOCALMSPID=${org}Org \
#         -e CORE_PEER_TLS_ENABLED=true \
#         -e CORE_PEER_TLS_CERT_FILE=$TLS_PATH/server.crt \
#         -e CORE_PEER_TLS_KEY_FILE=$TLS_PATH/server.key \
#         -e CORE_PEER_TLS_ROOTCERT_FILE=$TLS_PATH/ca.crt \
#         -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/${org}.islab.re.kr/users/Admin@${org}.islab.re.kr/msp \
#         -e CORE_PEER_ADDRESS=peer0.${org}.islab.re.kr:7051 \
#         cli peer lifecycle chaincode install mychaincode.tar.gz \
#             --peerAddresses peer0.${org}.islab.re.kr:7051 \
#             --tlsRootCertFiles ${TLS_PATH}/server.crt
# }

# function allqueryInstalled() {
#     queryInstalled blockchain
#     queryInstalled ai
#     queryInstalled security
# }

# function queryInstalled() {
#     org=${1:-blockchain}
#     TLS_PATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/${org}.islab.re.kr/peers/peer0.${org}.islab.re.kr/tls
#     docker exec -i -t \
#         -e CORE_PEER_LOCALMSPID=${org}Org \
#         -e CORE_PEER_TLS_ENABLED=true \
#         -e CORE_PEER_TLS_CERT_FILE=$TLS_PATH/server.crt \
#         -e CORE_PEER_TLS_KEY_FILE=$TLS_PATH/server.key \
#         -e CORE_PEER_TLS_ROOTCERT_FILE=$TLS_PATH/ca.crt \
#         -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/${org}.islab.re.kr/users/Admin@${org}.islab.re.kr/msp \
#         -e CORE_PEER_ADDRESS=peer0.${org}.islab.re.kr:7051 \
#         cli peer lifecycle chaincode queryinstalled \
#             --peerAddresses peer0.${org}.islab.re.kr:7051 \
#             --tlsRootCertFiles ${TLS_PATH}/server.crt

# }

# function allapproveForMyOrg() {
#     approveForMyOrg blockchain
#     sleep 1
#     allcheckCommitReadiness
#     approveForMyOrg ai
#     sleep 1
#     allcheckCommitReadiness
#     approveForMyOrg security
#     sleep 1
#     allcheckCommitReadiness
# }

# function approveForMyOrg() {
#     org=${1:-blockchain}
#     TLS_PATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/${org}.islab.re.kr/peers/peer0.${org}.islab.re.kr/tls
#     ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/islab.re.kr/orderers/orderer0.islab.re.kr/msp/tlscacerts/tlsca.islab.re.kr-cert.pem
#     # sample chaincode
#     # docker exec -i -t \
#     #     -e CORE_PEER_LOCALMSPID=${org}Org \
#     #     -e CORE_PEER_TLS_ENABLED=true \
#     #     -e CORE_PEER_TLS_CERT_FILE=$TLS_PATH/server.crt \
#     #     -e CORE_PEER_TLS_KEY_FILE=$TLS_PATH/server.key \
#     #     -e CORE_PEER_TLS_ROOTCERT_FILE=$TLS_PATH/ca.crt \
#     #     -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/${org}.islab.re.kr/users/Admin@${org}.islab.re.kr/msp \
#     #     -e CORE_PEER_ADDRESS=peer0.${org}.islab.re.kr:7051 \
#     #     cli peer lifecycle chaincode approveformyorg \
#     #         -o orderer0.islab.re.kr:7050 \
#     #         --tls --cafile $ORDERER_CA \
#     #         --channelID dev-channel \
#     #         --name mychaincode \
#     #         --version 1.0 \
#     #         --package-id mychaincode_1.0:29c02707eeac8b0ea3a398bda48ecb8365216e2d2ce3d327f9a645465219cf2b \
#     #         --sequence 1 \
#     #         --signature-policy "OR('blockchainOrg.member','aiOrg.member','securityOrg.member')"

#     # my chaincode
#     docker exec -i -t \
#         -e CORE_PEER_LOCALMSPID=${org}Org \
#         -e CORE_PEER_TLS_ENABLED=true \
#         -e CORE_PEER_TLS_CERT_FILE=$TLS_PATH/server.crt \
#         -e CORE_PEER_TLS_KEY_FILE=$TLS_PATH/server.key \
#         -e CORE_PEER_TLS_ROOTCERT_FILE=$TLS_PATH/ca.crt \
#         -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/${org}.islab.re.kr/users/Admin@${org}.islab.re.kr/msp \
#         -e CORE_PEER_ADDRESS=peer0.${org}.islab.re.kr:7051 \
#         cli peer lifecycle chaincode approveformyorg \
#             -o orderer0.islab.re.kr:7050 \
#             --tls --cafile $ORDERER_CA \
#             --channelID dev-channel \
#             --name mychaincode \
#             --version 1.0 \
#             --package-id mychaincode_1.0:3e94de7b2e34af5406a24b16335a04310d7953f8019268dee9947c655d8f9186 \
#             --sequence 1 \
#             --signature-policy "OR('blockchainOrg.member','aiOrg.member','securityOrg.member')"
# }

# function allcheckCommitReadiness() {
#     checkCommitReadiness blockchain
#     checkCommitReadiness ai
#     checkCommitReadiness security
# }

# function checkCommitReadiness() {
#     org=${1:-blockchain}
#     TLS_PATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/${org}.islab.re.kr/peers/peer0.${org}.islab.re.kr/tls
#     ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/islab.re.kr/orderers/orderer0.islab.re.kr/msp/tlscacerts/tlsca.islab.re.kr-cert.pem
#     docker exec -i -t \
#         -e CORE_PEER_LOCALMSPID=${org}Org \
#         -e CORE_PEER_TLS_ENABLED=true \
#         -e CORE_PEER_TLS_CERT_FILE=$TLS_PATH/server.crt \
#         -e CORE_PEER_TLS_KEY_FILE=$TLS_PATH/server.key \
#         -e CORE_PEER_TLS_ROOTCERT_FILE=$TLS_PATH/ca.crt \
#         -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/${org}.islab.re.kr/users/Admin@${org}.islab.re.kr/msp \
#         -e CORE_PEER_ADDRESS=peer0.${org}.islab.re.kr:7051 \
#         cli peer lifecycle chaincode checkcommitreadiness \
#         -o orderer0.islab.re.kr:7050 \
#         --channelID dev-channel \
#         --tls --cafile $ORDERER_CA \
#         --name mychaincode \
#         --version 1.0 \
#         --sequence 1 \
#         --signature-policy "OR('blockchainOrg.member','aiOrg.member','securityOrg.member')"

# }

# function commitChaincodeDefinition() {
#     org=${1:-blockchain}
#     TLS_PATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/${org}.islab.re.kr/peers/peer0.${org}.islab.re.kr/tls
#     ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/islab.re.kr/orderers/orderer0.islab.re.kr/msp/tlscacerts/tlsca.islab.re.kr-cert.pem
#     PEER_AI_TLS_CA_CERT=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/ai.islab.re.kr/peers/peer0.ai.islab.re.kr/tls/ca.crt
#     PEER_SECURITY_TLS_CA_CERT=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/security.islab.re.kr/peers/peer0.security.islab.re.kr/tls/ca.crt
#     PEER_BLOCKCHAIN_TLS_CA=$TLS_PATH/ca.crt
#     docker exec -i -t \
#         -e CORE_PEER_LOCALMSPID=${org}Org \
#         -e CORE_PEER_TLS_ENABLED=true \
#         -e CORE_PEER_TLS_CERT_FILE=$TLS_PATH/server.crt \
#         -e CORE_PEER_TLS_KEY_FILE=$TLS_PATH/server.key \
#         -e CORE_PEER_TLS_ROOTCERT_FILE=$TLS_PATH/ca.crt \
#         -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/${org}.islab.re.kr/users/Admin@${org}.islab.re.kr/msp \
#         -e CORE_PEER_ADDRESS=peer0.${org}.islab.re.kr:7051 \
#         cli peer lifecycle chaincode commit \
#             -o orderer0.islab.re.kr:7050 \
#             --tls --cafile $ORDERER_CA \
#             --channelID dev-channel \
#             --name mychaincode \
#             --version 1.0 \
#             --peerAddresses peer0.ai.islab.re.kr:7051 \
#             --tlsRootCertFiles $PEER_AI_TLS_CA_CERT \
#             --peerAddresses peer0.security.islab.re.kr:7051 \
#             --tlsRootCertFiles $PEER_SECURITY_TLS_CA_CERT \
#             --peerAddresses peer0.blockchain.islab.re.kr:7051 \
#             --tlsRootCertFiles $PEER_BLOCKCHAIN_TLS_CA \
#             --sequence 1 \
#             --signature-policy "OR('blockchainOrg.member','aiOrg.member','securityOrg.member')"
# }

# function queryCommitted() {
#     org=${1:-blockchain}
#     TLS_PATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/${org}.islab.re.kr/peers/peer0.${org}.islab.re.kr/tls
#     ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/islab.re.kr/orderers/orderer0.islab.re.kr/msp/tlscacerts/tlsca.islab.re.kr-cert.pem
#     docker exec -i -t \
#         -e CORE_PEER_LOCALMSPID=${org}Org \
#         -e CORE_PEER_TLS_ENABLED=true \
#         -e CORE_PEER_TLS_CERT_FILE=$TLS_PATH/server.crt \
#         -e CORE_PEER_TLS_KEY_FILE=$TLS_PATH/server.key \
#         -e CORE_PEER_TLS_ROOTCERT_FILE=$TLS_PATH/ca.crt \
#         -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/${org}.islab.re.kr/users/Admin@${org}.islab.re.kr/msp \
#         -e CORE_PEER_ADDRESS=peer0.${org}.islab.re.kr:7051 \
#         cli peer lifecycle chaincode querycommitted \
#             --channelID dev-channel \
#             --name mychaincode
# }

# function chaincodeInvoke() {
#     org=${1:-blockchain}
#     TLS_PATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/${org}.islab.re.kr/peers/peer0.${org}.islab.re.kr/tls
#     ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/islab.re.kr/orderers/orderer0.islab.re.kr/msp/tlscacerts/tlsca.islab.re.kr-cert.pem
#     docker exec -i -t \
#         -e CORE_PEER_LOCALMSPID=${org}Org \
#         -e CORE_PEER_TLS_ENABLED=true \
#         -e CORE_PEER_TLS_CERT_FILE=$TLS_PATH/server.crt \
#         -e CORE_PEER_TLS_KEY_FILE=$TLS_PATH/server.key \
#         -e CORE_PEER_TLS_ROOTCERT_FILE=$TLS_PATH/ca.crt \
#         -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/${org}.islab.re.kr/users/Admin@${org}.islab.re.kr/msp \
#         -e CORE_PEER_ADDRESS=peer0.${org}.islab.re.kr:7051 \
#         cli peer chaincode invoke \
#             -o orderer0.islab.re.kr:7050 \
#             --tls --cafile $ORDERER_CA \
#             --channelID dev-channel \
#             --name mychaincode \
#             -c '{"Args":["InitLedger"]}'

# }

# function chaincodeQuery() {
#     org=${1:-blockchain}
#     TLS_PATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/${org}.islab.re.kr/peers/peer0.${org}.islab.re.kr/tls
#     ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/islab.re.kr/orderers/orderer0.islab.re.kr/msp/tlscacerts/tlsca.islab.re.kr-cert.pem
#     docker exec -i -t \
#         -e CORE_PEER_LOCALMSPID=${org}Org \
#         -e CORE_PEER_TLS_ENABLED=true \
#         -e CORE_PEER_TLS_CERT_FILE=$TLS_PATH/server.crt \
#         -e CORE_PEER_TLS_KEY_FILE=$TLS_PATH/server.key \
#         -e CORE_PEER_TLS_ROOTCERT_FILE=$TLS_PATH/ca.crt \
#         -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/${org}.islab.re.kr/users/Admin@${org}.islab.re.kr/msp \
#         -e CORE_PEER_ADDRESS=peer0.${org}.islab.re.kr:7051 \
#         cli peer chaincode query \
#             --channelID dev-channel \
#             --name mychaincode \
#             -c '{"Args":["GetAllAssets"]}'
# }

function usage {
    echo 'up | down | generate | channel | deployCC'
}

function channel_usage {
    echo 'create | join'
}

function chaincode_usage {
    echo 'install | invoke | query'
}

function all {
    generate cryptogen
    up
    # channel create blockchain rsh
    # channel create blockchain dev
    # channel create blockchain playground
    # sleep 10s
    # channel join blockchain rsh
    # channel join blockchain dev
    # channel join blockchain playground
    # channel join ai dev
    # channel join ai playground
    # channel join security dev
    # channel join security rsh
    # chaincode install
    # chaincode invoke
    # sleep 5s
    # chaincode query
}

# function chaincode_install {
#     packageChaincode
#     allinstallChaincode
#     allqueryInstalled
#     allapproveForMyOrg
#     commitChaincodeDefinition blockchain
#     queryCommitted blockchain
# }

# function chaincode_invoke {
#     chaincodeInvoke blockchain
# }

# function chaincode_query {
#     chaincodeQuery blockchain
# }

function chaincode {
    case $1 in
        install | invoke | query)
            cmd=$1
            shift
            chaincode_$cmd $@
            ;;
        *)
            chaincode_usage
			exit
            ;;
    esac
}

function channel {
    case $1 in
        create | join )
            cmd=$1
            shift
            channel_$cmd $@
            ;;
        *)
            channel_usage
			exit
            ;;
    esac
}

function main {
    case $1 in
        all | up | clean | down | generate | channel | chaincodeinstall | chaincode )
            cmd=$1
            shift
            $cmd $@
            ;;
        *)

            usage
			exit
            ;;
    esac
}

main $@