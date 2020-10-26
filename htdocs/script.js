$(document).ready(function() {
  $('.t_root').hide();
  $('.t_message').hide();
  console.log('Loaded');

  $('.u_indicators_spectrum').spectrum({
    chooseText:"Set Background",
    cancelText:null,
    color:'yellow',
    move:function(color){
      $('.f_result_image_container').css('background-color',color.toHexString());
    },
    change:function(color){
      $('.f_result_image_container').css('background-color',color.toHexString());
    },
  });

  $('#form').submit(function(event) {
    $('.t_root').hide();
    $('.t_message').text('Checking....').show();
    var domain = $('input[name=domain]').val();
    console.log('Request for '+domain);
    $.ajax({
      type : 'POST',
      url : '/checkdomain',
      data : {
        'domain' : domain
      },
      dataType : 'json'
    }).fail(function() {
       $('.t_message').text('Error!').show();
    }).done(
      function(data) {
        if(!data) {
          $("#form .f_error").text('Unknown error retrieving BIMI Record');
          return;
        }
        if(data.error) {
          $("#form .f_error").text(data.error);
          return;
        }
        $("#form .f_error").text('');
        console.log(data);

        function boo(condition,good){
          if(good){
            if(condition){
              return $('#template .yes_good').html();
            }
            else{
              return $('#template .no_bad').html();
            }
          }
          else{
            if(condition){
              return $('#template .yes_bad').html();
            }
            else{
              return $('#template .no_good').html();
            }
          }
        }

        function format_errors(errors){
          var error_html = '';
          errors.forEach(function(error){
            $('#template .error .item .error_code').text(error.code);
            $('#template .error .item .error_description').text(error.description);
            $('#template .error .item .error_detail').text(error.detail);
            error_html += $('#template .error .item').html();;
          });
          $('#template .error .container .item_placeholder').html(error_html);
          return $('#template .error .container').html();
        }

        function format_chain(chain){
          chain_html = '';
          chain.forEach(function(cert){
            $('#template .chain_cert .item .index').text(cert.index);
            $('#template .chain_cert .item .alt_name').text(cert.alt_name);
            $('#template .chain_cert .item .has_logotype_extn').html(boo(cert.has_logotype_extn,true));
            $('#template .chain_cert .item .has_valid_usage').html(boo(cert.has_valid_usage,true));
            $('#template .chain_cert .item .is_expired').html(boo(cert.is_expired,false));
            $('#template .chain_cert .item .is_valid').html(boo(cert.is_valid,true));
            $('#template .chain_cert .item .is_valid_to_root').html(boo(cert.is_valid_to_root,true));
            $('#template .chain_cert .item .issuer').text(cert.issuer);
            $('#template .chain_cert .item .not_before').text(cert.not_before);
            $('#template .chain_cert .item .not_after').text(cert.not_after);
            $('#template .chain_cert .item .subject').text(cert.subject);
            $('#template .chain_cert .item .valid_to_root_via').text(cert.valid_to_root_via);
            if(cert.errors.length > 0) {
              $('#template .chain_cert .item .erorrs').text(format_errors(cert.errors));
            }
            else {
              $('#template .chain_cert .item .erorrs').text('');
            }
            chain_html += $('#template .chain_cert .item').html();;
          });
          $('#template .chain_cert .container .item_placeholder').html(chain_html);
          return $('#template .chain_cert .container').html();
        }

        $('.f_item').text('');
        $('.t_base').hide();
        $('.t_message').text('').hide();
        $('.t_root').show();

        $('.f_request_domain').text(data.request.domain);
        $('.f_request_selector').text(data.request.selector);

        $('.f_response_domain').text(data.response.record.retrieved_domain);
        $('.f_response_selector').text(data.response.record.retrieved_selector);
        $('.f_response_record').text(data.response.record.retrieved_record);

        $('.f_response_record_version').text(data.response.record.version);

        $('.f_response_record_is_valid').html(boo(data.response.record.is_valid,true));
        if(data.response.record.errors.length > 0) {
          $('.t_response_record_errors').show();
          $('.f_response_record_errors').html(format_errors(data.response.record.errors));
        }

        if(data.response.record.location) {
          $('.t_location').show();
          $('.f_response_record_location_uri').text(data.response.record.location.uri);
          $('.f_response_record_location_is_valid').html(boo(data.response.record.location.is_valid,true));
          if(data.response.record.location.errors.length > 0) {
            $('.t_response_record_location_errors').show();
            $('.f_response_record_location_errors').html(format_errors(data.response.record.location.errors));
          }
          if(data.response.record.location.indicator) {
            $('.t_location_indicator').show();
            $('.f_response_record_location_indicator_uri').text(data.response.record.location.indicator.uri);
            $('.f_response_record_location_indicator_is_valid').html(boo(data.response.record.location.indicator.is_valid,true));
            if(data.response.record.location.indicator.errors.length > 0) {
              $('.t_response_record_location_indicator_errors').show();
              $('.f_response_record_location_indicator_errors').html(format_errors(data.response.record.location.indicator.errors));
            }
          }
        }

        if(data.response.record.authority) {
          $('.t_authority').show();
          $('.f_response_record_authority_uri').text(data.response.record.authority.uri);
          $('.f_response_record_authority_is_valid').html(boo(data.response.record.authority.is_valid,true));
          if(data.response.record.authority.errors.length > 0) {
            $('.t_response_record_authority_errors').show();
            $('.f_response_record_authority_errors').html(format_errors(data.response.record.authority.errors));
          }
          if(data.response.record.authority.vmc) {
            $('.t_authority_vmc').show();
            $('.f_response_record_authority_vmc_uri').text(data.response.record.authority.vmc.uri);
            $('.f_response_record_authority_vmc_is_valid').html(boo(data.response.record.authority.vmc.is_valid,true));
            if(data.response.record.authority.vmc.errors.length > 0) {
              $('.t_response_record_authority_vmc_errors').show();
              $('.f_response_record_authority_vmc_errors').html(format_errors(data.response.record.authority.vmc.errors));
            }
            $('.f_response_record_authority_vmc_is_cert_valid').html(boo(data.response.record.authority.vmc.is_cert_valid,true));
            $('.f_response_record_authority_vmc_is_expired').html(boo(data.response.record.authority.vmc.is_expired,false));
            $('.f_response_record_authority_vmc_is_valid_alt_name').html(boo(data.response.record.authority.vmc.is_valid_alt_name,true));
            $('.f_response_record_authority_vmc_has_valid_usage').html(boo(data.response.record.authority.vmc.has_valid_usage,true));
            $('.f_response_record_authority_vmc_issuer').text(data.response.record.authority.vmc.issuer);
            $('.f_response_record_authority_vmc_not_before').text(data.response.record.authority.vmc.not_before);
            $('.f_response_record_authority_vmc_not_after').text(data.response.record.authority.vmc.not_after);
            $('.f_response_record_authority_vmc_subject').text(data.response.record.authority.vmc.subject);
            if(data.response.record.authority.vmc.chain) {
              $('.t_authority_vmc_chain').show();
              $('.f_response_record_authority_vmc_chain_is_valid').html(boo(data.response.record.authority.vmc.chain.is_valid,true));
              $('.f_response_record_authority_vmc_chain_certs').html(format_chain(data.response.record.authority.vmc.chain.certs));
            }
            if(data.response.record.authority.vmc.indicator) {
              $('.t_authority_vmc_indicator').show();
              $('.f_response_record_authority_vmc_indicator_is_valid').html(boo(data.response.record.authority.vmc.indicator.is_valid,true));
              if(data.response.record.authority.vmc.indicator.errors.length > 0) {
                $('.t_response_record_authority_vmc_indicator_errors').show();
                $('.f_response_record_authority_vmc_indicator_errors').html(format_errors(data.response.record.authority.vmc.indicator.errors));
              }
            }
          }
        }

        $('.f_result_result').text(data.result.result);
        $('.f_result_authentication_results').text(data.result.authentication_results);

        if ( data.result.result == 'pass' ) {
          $('.t_pass').show();
          $('.f_result_header_indicator').text(data.result.header['BIMI-Indicator']);
          $('.f_result_header_location').text(data.result.header['BIMI-Location']);
          //var indicator = data.result.header['BIMI-Indicator'];
          //var indicator_xml = atob(indicator)
          //$('.f_result_image_container').html(indicator_xml);
          //$('.f_result_image_container svg').css('height','100%');
          //$('.f_result_image_container svg').css('width','100%');
          $('.f_result_image_container').html("<img src='"+data.response.record.location.uri+"'>");
          $('.f_result_image_container img').css('height','100%');
          $('.f_result_image_container img').css('width','100%');
        }
      }
    );
    return false;
  });
});

