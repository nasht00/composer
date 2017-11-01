ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.14.3
docker tag hyperledger/composer-playground:0.14.3 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� 9�Y �=�r�r�Mr�����*��>a��ZZ���pH����^EK�ěd���C�q8��B�R�T>�T����<�;�y�^ŋdI�w�~�HL��t7�Y�j�>���B��{u;F��k�O�L�#�0��BP�OĠ	˂�O1$E@x ���lh��6aG���-{�+�2-�����,dv4Y����.�L�6�d~0`����Z�IY��F���ud��T����i[.I |����#��?�Y2:���2�R�({|TL>ďr�Lz��= �z���B�j���d��yٰ
mHPfc0,�K��r>�Cږ#=A��c�L���~Ad�X�iÊH5�M+�J�b2����X��0�ۈ��hHwq碾���?�6Ot�@�M:���5MG�;�𺭡�`���Eͯ"K5����?�0�b�AG��(ؤ�ǭ#.Bl��	ԋ66~��[h���P���U�(jP���Z;t���� �Ud�[:��{tH�1u*z�l����Gُ.a��#ڂ݈�;��|�X�
�U+�}�Q���ZV;��u�̺�-/�U�-���߰�6i�
��Нn���D�9�����c�`=���裃,�\8fJ]���E�>��:D�oK1�ɺs7�2fb��pt�^D����b���*�AG�fti#Ӏ�`.���>x��瞅?��WE������"�м��� �
���
>��d|��ߌ�	�p�p�W�ո/6����/J1e������:�_<�!Pь@Z��"�on���U5�zL��:��?�ʅx��σm��#hw��S���!	6��|ž��3��>��j�bpm������0���Pm�:�_X�xl�O���'�!���K�!Q��rP\��*�.:�ޛ���c;b���Q�tzk�md�"+����Y�ٲ5l��Z�M7�H�i٠�te��m�Z�T4�t+2y����w�;<u����YВ'�B���{�6ƺ��9oQ�C�n`sz�)��p��5��i ���E��$�"��V��ご�M���v��u�v�Ea�-���֨�Gӫ>h��ö������G���7�w�5@��E�;��� �kUCc4)&��Ǡ?�l�R_�Js�~y���>"��=�N=�!5�l�����3����'�ۡ���K�?�<��_��H8H�R"����J`<��做c��|`7����hT��Z��H!�c�Q���a%����m��Žͭ*S!ж���6���[M�$��a�<x���4��@j���!a{����� @6��z���2W�si�9�.��^����[�A�Q�}ڋ�a��^co�, -�E�İ�\�g�#�=�&�m��n�EkT�1�])2�F�6?�v���l��df��TG��6�Q�Li6�됱��Х蓘�O����`Ŋ���{䂄\��lV��^��c�n��rq��bp�?�����Tt�� �E6�g�s�Gko�)'���F���d�>�)3~����t�<o�@N���U�r�����l3sz@�D����q����W7+0���l�YP��@��k��?U����p���p(�^����?_7̰��X>�%�O����
GdA"� j��Z��*����}7:s7�͌H�Fc&�y��iV��1MJ�8�`��%2��O�&\i?S�P�2ǥ�_�kB^5����
������r�9��ʾ+䦔X!�p�,3G���Q��ż@��cX�~Ibt�iQ�!�I���
{ޡ"��O�P�+�盓���t�rS�bI)�>�2��Q�4_�	�Y��!�e!2XUk�F&j�!�4,4���?�|��/6١<"���[�9��ޟ������`�"a��\QwA�D�N��L����E�@�ui�,i�t�N x�J���_�x��F��jAP�I-⿢9l��W���F���w��>����?I�����:���a����C. ��P��$\��*���{��a�3���ADׁ��6QM����
�M�k�so�a�S��y���gD���?W�ǟ-q����7����$����U�m��>�������������������$]�c�,�M��4���MͰ���4����Kp�����];�B?9&�B|��M���/������OD�����1�7�]�,���Y6jzȈH�yA��"#z���^�n�_m��^�u_8an�LE���Ա
uzH�F�3�|f�i����V	��"�3F{
ytc&��#v�H�U&^+����S7p�;�3t�O����@�4�!�on���s(|�����O$$�bX����k��
���E�z�z�c�;"bú�K!;>:�]}}��5?78Dk���4�^{�e�O���2|�	[EF�.��w��Q�LTY<�����
Xf�!y���$�����J���V���-�ްAe(��1����z`F�G��nk��y)���o��P�E���$G��?W���Gy���e5D�;�Ч�C*n� 6� ��'`�9 �ìc@�V��|�yT9�=�P�pn%*�$ �Y��i�k��s�*�m��=H��Ϸ��vы��K3�-ef��k��e�`���l7Ɉ��K��N�1QG�_�Ʉ>K3qx	$fdؘJ43s���d�cLT˅1�ԩD2���G�da���S��J�3����Q�̬�Kh���FV�{%�nl�W3������u���?�p������b$(���Ww��sݓ߾\ƃ����B("M��.	���
���o������w��������S��O@���ʲݩ��*�QX��du'�*QI�"�"��r��*���hT�DvBRe'���o�?�M�P6���[���5��@d�����K:�m<�~���ذ�ikNk�6����`����뛍?3I�߿����~�r�Y���w���7�����'��ק&Y����?o<%H3,�) z�`�+�������{�]�����N<n��%R�d�������O�a����X�����/�����J��[c�'�K�Jʆ+�ARz��%kd��A7�O��Lm:Y��^�V��l��{Ee+��+5A�����N�T���Fe)��b(�S����;���P�C�BR��UD�j���9>
�d:��d��Ie�J)�J��L&����5^W���R���sd��^���X���D4�l��n�~�9�癫!Ip��U�PP�iE,'c�l��${��R
�z*ś�F%��*��<M^�.���L-%N�3-�~g���s&�Wg��e���q1p)���ί����F��&f�CI��O(��ɖ�R���8l����7�\��vs)[�G��tJ�.X�0({g�^�*ټՍ��'�|:�}}R�J����h���A^JY�����B��R�4˻-����e)�d�罳��|���\%k٘�0�n�4Z��iH!}ad�!�S����[�N�;'=˦c���bV�*�d:�>w����Qbig��2����b){�;������"d��N�ױ}�yz���<PR�ZԴP6r9ow;�b$ce�ǅ���݃�R)v�Ud2D�j����y:������}�_�Ɣ�NR�P�lܢ��f��f6~�db-�:�X&}g���f�����"��GG�O����:�O���*x�22�qE�+�d9���e� ~gē�����w�U4t4���D&���i�{�ī�z�^�q+��W�)�l�d���F��;��Iv�
Z/.G#�j�\P��L哹�3����?����C�h>����l���/����a, �b���>|$y&`��M��Ex˞�J�����nM��۾������}�3������U�X�t\Ȝ��$�X�S.�I�9YY4G��B�*��B�{x;�Z �5+����r"�7(�>����J ��p�7$�AB����N�ʗs�v�ܼJ�x��Չ܊��E՟r�I���B�PJG��ɾ����ƩQ��)IH��H���ab�$��e8�g���ܽ����1��7���z�_|��ߩ|�ɗ1�K3������J`|�/�3���?��&�g���G\��BJ^M��JF�f2�(�R�u���,����q+���G��T��D�S8㜤
��
>i���+۰[�r�-�{)D��F���	���7>�OK��{���`��������V���-~%l������c��!YX�Y	<q���\d&�%�̶(�
��������S�ǉ7�C7����˭i������ �5��=�td�-�@�4Cc'�p��ꂆv�6�-Ђ���'ީ%`�*���"��CZ�a�Sz�G��9�#8# $pj�.;_���7���He�XD���A�ˎ QW�#��ӏ$e�ct�ز�_�t��y��[k1=��(*<����.>��2�#͝>����h��=dK�����h�I���W�%=���Ǯ�T��L��YA;�Gϝ����,���-Х��`ɔH(!�}�F/]kt)xtX��@h h��G�B"�mj�"��d��(oK�"T���*��goϦ,����hdy�Jf��kEy	,hX^�W:��1:q�g�puc눹�o3Y��V���ф���$�1�*��gHph�x��/����Kwt�I»=���k������|s5����r�V��m�i`��-&m�4�$5�1!��K`"�M������T{��N�~cR���A�{�'%s���Mq�+E(vh� �����`U��'r,����"U�9������Ͽ��wG��'�HM��M�vi���#�=F�N.�=� S<8��M+�1n��Z����ʻ��x��1l�8P�3�ɯ7�K*��*�J�fB��*m�t�v�|E,�QE�`�H�o{�fMߡ�O�R�d��j����l�x�?a�9L,{�ٵC�Ҏ�I�[���!NE��X��v�F���G�s�n&k���&�S�n�_���s�ģ�%H�P�|�ڐ^ź���IsJ>�ö��s��v�.F&C��1K��:L�>���⣙S��ٻ�ױ����4���ir�\�!�f�Q���I���ر�8��<Y���I�8���8�]iZi@�A�@�CblaX ��ĂB�5�?�<�q�n�^�uZ]��>����w�߀���~w�
�5,����>����(��� �A���wk���D���UG��6�� &��q��'#�6��&�{��A��a8����џ�������ߞ��7���R�o������/~���%��8�9�|G�ȯ�����:��
�n]C���wI:�(���dD��Q'�m)<����p2N��8A�TL�	��ȱ8�D�_(�z��W~��~��'~���~���.������$�;�=,�[X�?@�^�h��_��� ���z?��] �o���? _˅п=}� �O��t�m��{��~��bE�S�Z��eZ�^,V96�L<�RF�b�s�v��A?_(9�Ϯ �
�)��W!tUSd�N�X܏���";vXQj�ٟ�Q��ȭB�7b�H���l?[:ϊ�3DL��Ċ�8����UI,��M�	ר-&�a|��=�԰�|��-\��@vK�L�5�M�Dn.�V҂N�k�����d��[�Te� �X��T��~��7�����8�FE�,�cau�Y�C%{�C���7)Ӓ��_���P�&���&��g��R�x�Bz�d27/���\M�*����ɹ���,t���be{������ b,cϏ�4R�0g�̒��b1 z�b&rV$y�[�dS?�|7M��Lb���!��PVoL��P/��Ѡӛ���E�dWYb�nb9��z�o���&���tju�e+���;!�����쬛Ru�]�hy^+W��Ř��EK��9��
U�bG�U�2�>��a�G�%7�{��z��y��x��w��v��u��t��s��r��q��\^��ț�4C��?):�W2J�j��W;��.�8�_�t.���Rb��U;�KQ;k
\�5%�X!@��F� ࡘn�X� @��L�Ĭ�� t�hb������z��*гVJE3�Ȃ%��M<1�h�&U���>O
�x-M��B�X�0�9�i5�&��l�,]��S�O��ܡ��������hs�t�L��d$^�s�U=O:���Le���"�V�W<�.T?Y&='�y���8��C��RV�`+��5jݸ��"f&�S���ԳQf���P�T���ѕf%?m�prg��$��=�/�2���_��v��^}:
�e����k���\��/��ox]��wo�z%�b�E�O8��`�ooc]k/C���9�Z�����Q7�~�Aݚ.z����q�BGv_��z���E�B�!�-|���������7��k>�у��~��<��+EYve�2E^�|���󒡱�����R�V:��/K/Z�'9�������m+���(��Pr!7��E[yz�����\�#���uE�enK��V<	��7h� �D�I��vۮ�ص�Y�x�bD3��"���NЙcnRP��"�dm~�ćx.?ĄV#}��BS;��i&1l�mc���E�d�X������&L2�1�����)�:�e��I$�^N��6x�;�1��=�J�iTL@ZP�nQc���WC�eЮ�T:��D�85���ܖ@�%�H�ǽ#4+��P��\��X����.�z��K��pX�1I�G�A=o[]�j�Ec8�Xm�6B�b+�O0��up�ǎ������([�m�^F�K!�\f<��+�&�o(T*â8�f�X6otg��jG�O^��������춁�\1U�@憹����X��I|D��\�_��2���g���Y�>����)�{�@��4����_rЪ�b�z*	n!W�Ȫ���VK�yW���H�,Wmr�Ѩ����+��J8aKY�lZ�a3�ۛ��P`F1-���C�繜�{T�ʈ��ʼc('D��Nf鳉�%��nm��q�X �n2��w���8Z띟�{:��E�r.T��TF�Q�e��RQ�1�<;m�c5լ��tm U�	�)G���tk(�7E>�(�$�a��D�R�Tg�Hke:���2�r��2�R�H�c�U��s��y%O�$�H�kE"����dTע3��Y�'G���jq�U$c+Ÿ�d���G������2Anz�)dm_�Ld{;�)�0�=����W+�rf)V�����ؠ�r�G
ԩ^��)��>a0��7�e�K�ci��:/7r(ŚY<G�ʸ�KE�Ul6אت7�
�4���d�y�-��V���%cd��9�.R�}�X��)2�I1-mI^_��D/��c,�%3T����R�1M����3"�NP*>.�;LV��2k�l&[�����<ʑ�Rj6۵x9��y�2f�����.��зl�a�.}7�N�t���x�2���|�B����-��9՜�b�#/��_D~��#cfHˉz/��1��~�G�O����z?���޳g����=�y����H���л�7�7��g�ϐ���FU�5��!q/��&q�W
�>A�K�Y��ݱ]QoL{���8#?��ɦ�(�O��)����������8��LU�P�z�|�b���ҡG��"/eV��ל���m���<�����+��atd��!��"��h��_p��î�Q���aN�tT�wr��y�3 ���U�_	����;���p�a
�J6�y*U��{q�!�wU ���=.wD�	�����sel����}�{�������g��AU�At�f�0���֧=���g��"�[w���E�U��W騘�=�8�Ӯ�-�j����xz��Q�H��f?|��HPP�!}���e=�:F�G10E�6��*,Զ� z� 1�&v*z��5�.��;l�(l[��`]����N�a���LW�#��Y`P ��֧A�Wf�|�f�' ����5Zb��v� �!���O����a�~��=.�;� $+hѝ���l���ѺO�Ի�ƫ���t<��e6���s���.��
f1 ��T/p~v�`���6���P49�?&��s��:�6�F6hǯ̩�$�qi�=_�6ѡ1	v�6`:�X`f��K��z�[`�ڨ�Md�$\�5����%d��]��\N _n���3r��O��Y�F�^�A]ןw�i�������8�jc��]�
]�z�g� ϯk�H�cÀ����/�����\�o���t��=���ު�3�woax��/�s�s�6A|G�� ��Na���'��i>!	���Е��řË0�t�-�����!;��SX��AI�^ɚ�:D�����6���r_����}���� @���Ke��D{깬��e��~�%AL����m�idq����kNx�h��u�b��c����<�б�~Z�"t�j�P9�ea=����0al�R���[���e 
�9� \�u導�"/¢S6���m8�k��v�N��P ~6�{(��[�BƂ�1-{�g�nͲKӞdg�����@.��~l9x��^�j�nKYwqݱ'k�6a��6��E6ػ���Ŗ��M�/�a�{l|S��۴�#ƽV5���-B$�M�6��ۨd��N��|��]O��SwFN��Zf��Pv�ùt�[�H�P�fu]���ry�?x�P8�a�Gcs�6����8}����'q,N�%E�r�ky]���N��$p���n(M�D �o1�n�+��0RMk<�rc�R~��qK��aT�P��Q�b��};»Z��X����:�y���7W�q��*JD���0x��~�w�V2ħħH@k;Vɞ������N�dlx����[g	�D�x��f�[�K�{
��R�/��r�]Ş�"_V
|<K
�k4�޵n��8�}2Q�h�o<_;2A(r'B�-B�[T4N�2Q#T��;�����h�e����J����i�$c�L��1pP{���@�'�
|����^�q;��v�7��~����(�,�?aN�u�|U�q�ESr����Ud'T���qY�i���Q,F�Ԉ�R@	9b�d,��Q�iY�'&�����9�?'V���)���m���t=A�{�ܖѓ��]7<ٙsOn�����ߓ�
��c�B�͗8�dSu���%&{�ͧ�|��>U�֬{q6�,�9��J|����van�oY(����sO�Q�Y���wr���K�`�b� pO�cW���v�04&�Y<WU }o���p:��'&��s5Ԙ�Ѯf�f-HK�k�ɴ���=���ξqa;��K��tmd{�c;/L���춺=Cv��H���%�)��N���=�/��SB.uV�������4#�yn���	�g+�ͬU��q������F��EQp���St:���#H��$h�̦�KO��y=n�`6���v߸|��.�Η�D>�Rg9^��K��=���/�n6��:΁�n&��S{��һ<:�3�zx.e�-K��;?9FbX��?M���{I�D��Hs�;&�/o����T<F�P����z<y���3��#�z㛋���c1�OD'�4u{����g��~b���[�|�v���b���+�D)�����ޣ6��K@yԱ_[��.7�B��Yq@k"�#�8��R��Ml��С
���@��o�x;�o׋6y׉�B�8`I��}��C�[��.��i����i����?Dz��#�o����ܯ�ݧW��7�������"�=���іo6�> b�o ��Ƚ�?Hz�?�c�򟊒����P������˞��l:�����/N9�7�������{4�h�=мP4/���+���'�׽�w�t(�OUⲽ�X�Dc
n�ǔV'B�UEnǣ1���1,։�#T4Ҋ�1��)*Nr�̸+��j�Wa���]��>��AR�������?��q]��h�W�Y�9�J�s4-6M\袳|��0�¢:�e/���DE�����1�v�tcN�*�Țzɕ���Z����FG.�fD^5�A�tZ�4��n�4���D5���y]�F��չ�c����w�^���������y���C��M�������!ҫ �	l���^�"J�_�|���ʧ{���][s�h׽�W|�V��o��IEE�7_"�	�׿�t�{Zg�Nw���^W��IZ���k��������c8��
����I��߂O������z������ �ZŽ�KT=����k������
���O9���)��P����'M�w�O����pT'�	Gu��G8
H�?���'�T�_�C�_�����	�g��?��+B���5 ���!��?I��*�Z�o���h�������w�uW�DL�t�~���e�34��e�ӹ�~b?��y{3:ƻw?o����v?���|2������}��}b+�$ة��U��J�{�6��n��5s�c���f�N�s��J����Al���x�i�lQ�Z��&v�)j]�����}��e����϶X�\�;�A=:���m0����fO�6I/��v5_d;�o�>��~�\�˃4���8`g�_3e#��g���BeZ�c,k��:t�?�m�0�[^<e��χ�^ײ�Q1kn��n�n�������� 
@=���s�?$����-������D�� ����*�?A��?A�S����G����<�a��.@���������+�3��U )��CP� P��a��>�:��\���k��I�TL�%u�Z'�M�߸���u�����R��xt1�/�����A�͸�:ȳ���|(��x��p���3-��{T�ռL(6��(�&iqAȥ���]g����T����5MC͟�z�u}$b�T׫�;�!���\�/%�*�T�K{�㿵�o_����N'd�$1�x��Xr)i��.VƔ�K&%�Ͷ��q[Lľs���x��$����=a��
l��4A�x�����ƜZ��������G����Ut��>��@����
�O}�Yx����%@��g���9C�B�%f�4��� �paȇ!�R>˅$�8�!C	T�G8���@����C�_~e�^�<}yN�t�l5M�Ӝ?�K�mD�A��βeLvqЖ���[<?��'z�8��8b<A�݋�	9kc�E�ۯ&�u
��b��� �sJ��j�(no�.Q:�f����q;<k����o
����5��k���
��P��$��j���w����u��(�?���W�G�R���6N�q��6v�sV��]��j�]z�2d�(O�/��ڣؾ:��A3�|�]!3�m�*�l^�I(�g��W1>�s�<��;��u!u�ǆc�7[��`l�"��M'����
4��$��5��������� �`��>����������^�4`@B�qܝ��(�U�5��W��_��1}hˢ7�wV5Q�ӻ��ٲ���R�����������Ϝ�==�g `��هg \�j��å�P�b�C ^=@�N����l�)���\�+o?��VSһ��km����r����z�>�Y�c̮({�\�U�Y��`��e�{�}7����[����og XnK*�Z�XmIW��7�'}�ӌ�Ad�O#I	x�<컑Tn�X�ysҧ�~nҮ�r���`YCjȭ���&Z��R�2&M�����P4TK�ԑ���c�j�c���t�w�$�����Rv�ۍ�,_�{b"-#��i߹�+���������E|�L�9�������h/�������A�U�����>Lx��*��k�?�~��������
�O��?��_	*���CU��������������������_o���5��G~�2~8���̟dD��/��ϲ�q8�����i>E�3^�h."|֏`��ÀB��h���O%���^?8�J-s��f�9$�$9��Y1za�Ftɚ�ZL�e��*�$���ŶKzi�[����]�?5�!��PR?K6�~��Iua�7�ˈ�E�^K�:g�ǎẤ��e��Zξ�S����(��	���?��T����[�Cݯ�w������g)��*���w�?��U�j�ߟm�xG����u�?I����W*�����FU����S�U����[�7������vd6.��Ծ�.I��ں���Z����VIs������9�gf�o�l�g��bl��̈�;Ւ��:��>��Y����l;�(�8s�L��9�������V���󩯋z˟�I���yY���i�1Y�V/��З�#��nc�^���~���Xy�8���{���4I���ު�7�lcG����{\n�FBv�������X4TW�,��u��d5��4�y����\l��hLdo�n1N�k���l�1��Y�J��W�����MFFg���E��43ݡ��Xve@A�]���[��p�;����s�?��$(��	��?����G����U����o����o�����8�wX�` 	��?��C����_*������$�������_����_������`��W>���o����	x�*��{���J���8~_�S��U�*�<������_?����u�f��p����_;��?@�W��!j�?����<8��?*Z��U�*�����*�?@��?��G8~
H�?�����������͐����H�?s7��_�X�(����h���� ��� ����W���p�����H�?��kZ��U���A��� � �� ����������J���˓������[�!��ϟ���?��^	����(��0�_`���a��_]������G����Ut��>��@����
�O}�Y���J�OW1��s<�x
���C:�C�&��"���xH�x�<������4���Q���(�?�P�ׄo���P]+�����K���\+N�*P������ǵ�ד�4i
�*`1�/�p��Df{�^��-%
ˡnm��b(��(�'9�\s��l�2�(G�F^�� �1z�r/֐�0�uĸ��Nby1޺izt�dD���T�㥧t<�D��H�kiw���~�
����5��k���
��P��$��j���w����u��(�?���W���2�s��w�Vc�gءћGrg9������l���"f���R�9��`��Y6�~�!���6K�GŚO8f3_��3qni��;=J�~�.���w�����5��t�����BeL���
4��w翃�[������w|o�@a�����������?����@�$����������xM�������?���(y,�٭=��剗b����_+����Y�ݤ�"y��&�`�Xbo������_eN�l(���ci�3͂�46S��8�:�,���h��1�sz���X_�K�,�nN�yIz1��%=�;�������8��N�2��.�|���ܖT�����b�%]�u�R4�W���/v�q<���i$)O��}7��M��<fN����M����e�P4TK�:�9pw�b,.$L&��3��7O#ls�}<
�vo��b"i�Ɍ"�B�O5b�և�L�4�:�wԪ9�f������
�$���Y������xk���	��͂P8G����q��?�������?AA���P���O�����Jt�/dQ���q��q��� �'q��K�W�j��9�2=�CU�������ߕ�Y����k���Ȳ8�|��0���ʶ��;� �f�2�:pE������"�/�2�}�4-�ώ�r�U/��5��s?�v�d�a�=����þz~V��_z���{��7��źެ˛syK-���-;�#���U�����$��:���,w�r��ٵ=P����Uثm|��r.��$�,[�I�l8�E���MF:��]�n:Z��u�O	Ɨ�}J�����-Z���{r���K;w}���O��cQ/������)��4���L��D�%��M�Ր�ݶ,������f�bˈ<��[���q�s�c�#*�*&��%6/1�e��|$��h,z�8��x�`��d""��K�����>O�	
Cb���=�����y�X��ʺ�����������+B5��<`	��9OФ/̩��O�l(�q������)a�S\��L�G�@�3���(�P����_���U�_9����\�x��6H�u�c�7�OG�`�/�Q��F��ȅ'E_����ʷj{�\����+>��3���a��*���#8�^���W	*����0��������������ʛ������;y"���T�ᄝ��;��w���¢�e�N-�'��f�a���V��a?��ݬ?���Đ�������~��|?�JvǒJ��Ꭼ�vJ6�ZK�=>�3aC����N#��/�!+ʛ 
�]�-��|\N6�n�hYwt�����~/�������$�،ѝ���q���D->_�i�NcQ��JQ��~b2�.������lF�D�^M��%ƙ�i囕[��~��F�_gxn)s����т^G�퍵e�n��������-V������h��+A��gC:�X�'pjΓ����GE� `|��}����f<��>I0�g^����@Tq����X�?*����Zv����h1~�<p���N���8��|�+E?TE���a'�����l��콲���⣿����w�E��WP�W�w��p�U��������?����_��b����v2����������	�%x��#���?���ݦ���8�z*����q1���~y��kH�K�C�����X����fRSs�9G@:5}� �#���ne y� ������cr�Σ6ק*�D��w���Zk��c�ȍ.�>�֪s)���� �Im �[��A]���<�+?}O>�W{�^2Z�O��+�[��.3W��ҕn�rz-qX_��ն+}Y	/�u���R>.�q��xgk��S��J�`��f����M��T\���00����Fa|�ɌgIo=�4�m�r��*��X�f*���Um�э^&������y�G��qI�<���n"��=^�[�ow;�l������Ev�l�� �#��Fق���Ju�����õ�mӘT:�4�Jc�灨�ٝ��eKN��f��^o���]P�!YK���"�Y�wHb�_u���89��_Q�?s��?M�?������	Y����^�����<�?����,�A�G.����O��ߙ ��	��	��`�����9� r	���m��A�a��?������꿥���� �ߠ����oP�����W�B}��������?���������;��̈l��*�z�� ���^�o����o&���Ӹ �k@�A���?I\���O�R��.z@�A���?uc��?r��PY�����p���P��?@���%�~c��?2��I!������\�����dD�2BБ����C��P�!�����P����������������\�?��##'�u!�����C��0��	P��?@����v��F������_���������˅�S7�?@�W&�C�!����!������������AJ�oi��Mp����}�y��2q������7� L\��sZ3��2sݪ�&eX��*Wh�d+&aP�aYzUK�Д�Wq����.�Q��OO���\�������NO�nQ�)N/����l�k�-�?l�~�������u"6x	O���@�k3�qm2�n�釁0�º�ht;h�lU��.�Fv���-��q���A˳�*I��H�Ͱ�f��oS�h���9W(|Wbz���W��w;v]��㥙W�x�&��`�f{P]�@q?�{W���sF����T���Y�<����?t�A�!�(���������<�?�������-R��{r\��8���bR5�p������v�[{ڿ�Mq�l���`�֍����zMLk�(m�T8��nU��w�-�6�FiӴ�sE����K��f��=mN.��.=	�v,�����|��e�E������glԿ�����/d@��A��������DH.�?����(�,�l��g�����k�vփ����U����Y�������n�}8�_�g�K�;��}:؆�m�p��[~oܥq�n�g�a�4��X�G��M�l�'����J����;����d�8Yw���#7��6�ZW��*Qsvh���k���Qg����)�_��϶\(�&;�m��w��s�B2���q��kܳ-88'�Ij����-Q�q���6�k�{e�ɩ�W�\�#��Qu7�G]ɨ�vV���v5t��z]�r�Ӟ�崙X0�^9�(	���خ�oU�T�=�ti�g��mH��n�5����6�k�`�4�Bŏ��_v�`��������?�F�NA�G�B���_,�d��//^���>=�������į���A�� �����P7�����\���?0��	����"�����G��ԍ���̈́<�?T�̞���k�?�� ������#��_ra�7������� ������˅����ȍ���Hȅ��\�����	���8��?��r\ٵ��w��A�ބ�[�U��6�6��H�ݗ���~��8%V`ߖ��|��8}�gr?N����NZ���۾��^�7�/���ݸ���G��`���(�Z�1�.Ve:�xלWׄ�^�>m�5ޙ�M�`8a��FHI��Q\T���ɺ�خ(�S�/��y���_�Fޯ��ǵ�s%�冖TFE��5��p��?Ԧ���9y�<rM�v�/�N�ò3�tb�����	K-'mA��8����z9L�����WukQrx�t��Y������P��!�V�Rx�Ygy?���`����W���n�{�����r��0���<���KȔ\��7�0��	P��A�/������`�������n�������r��4������=` �G������9��V;������l�~��������HQ�Ak2������w��OɾO�;c�[��ᒦ�G9 ���� TvѦ^�B��55�iV�f��W�Y/h�[�6U��Bg�}3*ar��+D��O���*��i���2��7B�XTe�i��~ vJ�39 �)	��r z	��8�7WE�*\���]-^�Sb<�o�QD�zT�y���]A�騺V��Pi�&���N�;��$i�Sԭ	�U��~z7��Ʌ�G�X��er���"�[�>�����<���Q�������J��Vf-���Z��y�I��u��	��H�TM�0,\cqˢSg�Za�9ü�~���3�����'��g��\�s��ؾKy�i:�#6���P5b1���ɬ�V�eݜ���e��C��O�Rsg� ��0���X
��r�¤%-'N`�5M���
s��dqqv���K�q>n�f�D���cR����x�~)y����':����E�P7������?t�B�!����e��D�wI��?t|O�/oWcgQ�;��8V+-)m��U��>�u��NK��qws����p�7�����F5���*		���X�∞���7�Ai~P�����%ݠ<��:+?
�dY��G���})�����h���?���� #$�_�������/����/����؀hȃ�G�e���9�o|��l����3�v�D��8np�*��/o��� |O���r ��B �s �K;�j+��7��-
.+���a��tc���QU%R�-Kec1���a��p��m�XZGZ{jA���2+��6�Z��������<^�F���㟯Un&S��\r�$�;��IK�4_ ��0`���6�JE�⡮TDY�K{�m��8�p-mk<�`���=^H��M��M�����S��~�⃽�}R8�'���ť������!�#��9ނQ�!wXٳ�j,?�����	��,#�?9̎���T�٘���pJ�����Ư��Ob_ߺ��c���>�3��S������CѠ�Yp��m�+��P����K����ǝ��A[����0.�9�'������k�y�x:�C���2�˝�>�
R�5��mlc~��������>o�O�����y���J���_��_�8��ޱ��k�V�l~y'���K���Sן�<F��}�g���y��`X
'˧�@H��Yx���o�U�]��k��a+�{7.�^�r�(.�a��,���m�:=1k͛G�Xdƅs�~�fƦ�nN#��j����g�i�TN��9Y
5�;f�؆��o���~x�jr�7o�Q0��?���y�+�����aO�������M��/�<}�{�ȯ�~{��i��_���wa���I ��
������y<�W���;f槫O��]-?,4��̹m����T����ӕ��z��޷�M'�p�y�gV������(ښ���?�z�w�%���_�����7y۵n��������zk�߰he���nM��,���E2�ל��i��G?���N��ۗ���~��x��X��S��T�O�]2c��|h�ҥg�%�U|���SJ[��E<~t�'�{⻎(�޵����e鹓�:�S�6:��y��O��Û/j���t�O/��<�珏��ǻ�                           �k���* � 