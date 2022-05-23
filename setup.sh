set -xe

hostname=arch
username=arch
password=123456

rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc --utc

sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
sed -i 's/^#zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo $hostname > /etc/hostname

is_intel_cpu=$(lscpu | grep 'Intel' &> /dev/null && echo 'yes' || echo '')
if [[ -n "$is_intel_cpu" ]]; then
  pacman -S --noconfirm intel-ucode --overwrite=/boot/intel-ucode.img
fi


  disk=$(df / | tail -1 | cut -d' ' -f1 | sed 's#[0-9]\+##g')
  pacman --noconfirm -S grub os-prober
 grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch
  grub-mkconfig -o /boot/grub/grub.cfg

sed -i 's/^# %wheel ALL=(ALL) ALL$/%wheel ALL=(ALL) ALL/' /etc/sudoers

useradd -m -g users -G wheel -s /bin/bash $username
echo "$username:$password" | chpasswd
